"""Núcleo experimental da linguagem-base BRX.

A sintaxe BRX é convertida para uma representação intermediária neutra. O
runtime de referência executa a IR; outros frontends podem produzir a mesma IR
sem depender deste parser em Python.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any
import ast
import json
import re


class BRXError(Exception):
    """Erro de análise, validação ou execução BRX."""


@dataclass(slots=True)
class Instruction:
    op: str
    args: dict[str, Any]
    line: int

    def to_dict(self) -> dict[str, Any]:
        def convert(value: Any) -> Any:
            if isinstance(value, Instruction):
                return value.to_dict()
            if isinstance(value, list):
                return [convert(item) for item in value]
            if isinstance(value, dict):
                return {key: convert(item) for key, item in value.items()}
            return value
        return {"op": self.op, "args": convert(self.args), "line": self.line}


@dataclass(slots=True)
class Module:
    name: str
    version: int
    instructions: list[Instruction]

    def to_dict(self) -> dict[str, Any]:
        return {
            "format": "BRX-IR",
            "version": self.version,
            "module": self.name,
            "instructions": [item.to_dict() for item in self.instructions],
        }

    def to_json(self, *, indent: int = 2) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=indent)


class Parser:
    """Parser estrutural do subconjunto BRX-IR v2."""

    def parse(self, source: str, module_name: str = "main") -> Module:
        lines: list[tuple[int, str]] = []
        for number, raw in enumerate(source.splitlines(), start=1):
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "#" in line:
                line = line.split("#", 1)[0].rstrip()
            if line:
                lines.append((number, line))
        instructions, index, terminator = self._parse_block(lines, 0, set())
        if terminator is not None or index != len(lines):
            number = lines[index][0] if index < len(lines) else 0
            raise BRXError(f"linha {number}: fechamento inesperado")
        return Module(module_name, 2, instructions)

    def _parse_block(self, lines, index: int, stops: set[str]):
        result: list[Instruction] = []
        while index < len(lines):
            number, line = lines[index]
            if line in stops:
                return result, index + 1, line
            if line in {"end", "else"}:
                raise BRXError(f"linha {number}: {line!r} sem bloco correspondente")

            if line.startswith("if "):
                then_body, next_index, term = self._parse_block(lines, index + 1, {"else", "end"})
                else_body: list[Instruction] = []
                if term == "else":
                    else_body, next_index, term = self._parse_block(lines, next_index, {"end"})
                if term != "end":
                    raise BRXError(f"linha {number}: bloco if sem end")
                result.append(Instruction("if", {"condition": line[3:].strip(), "then": then_body, "else": else_body}, number))
                index = next_index
                continue

            if line.startswith("while "):
                body, next_index, term = self._parse_block(lines, index + 1, {"end"})
                if term != "end":
                    raise BRXError(f"linha {number}: bloco while sem end")
                result.append(Instruction("while", {"condition": line[6:].strip(), "body": body}, number))
                index = next_index
                continue

            match = re.fullmatch(r"loop\s+([A-Za-z_]\w*)\s*:\s*(.+?)\s+(to|downto)\s+(.+)", line)
            if match:
                body, next_index, term = self._parse_block(lines, index + 1, {"end"})
                if term != "end":
                    raise BRXError(f"linha {number}: bloco loop sem end")
                name, start, direction, finish = match.groups()
                result.append(Instruction("loop", {"name": name, "start": start, "finish": finish, "direction": direction, "body": body}, number))
                index = next_index
                continue

            match = re.fullmatch(r"fn\s+([A-Za-z_]\w*)\s*\((.*?)\)", line)
            if match:
                body, next_index, term = self._parse_block(lines, index + 1, {"end"})
                if term != "end":
                    raise BRXError(f"linha {number}: função sem end")
                name, raw_params = match.groups()
                params = [item.strip() for item in raw_params.split(",") if item.strip()]
                if len(params) != len(set(params)) or any(not item.isidentifier() for item in params):
                    raise BRXError(f"linha {number}: parâmetros inválidos")
                result.append(Instruction("function", {"name": name, "params": params, "body": body}, number))
                index = next_index
                continue

            result.append(self._parse_line(line, number))
            index += 1
        return result, index, None

    def _parse_line(self, line: str, number: int) -> Instruction:
        if line.startswith("let "):
            return self._assignment("let", line[4:], number)
        if line.startswith("set "):
            return self._assignment("set", line[4:], number)
        if line.startswith("out "):
            return Instruction("print", {"value": line[4:].strip()}, number)
        if line.startswith("return "):
            return Instruction("return", {"value": line[7:].strip()}, number)
        if line == "return":
            return Instruction("return", {"value": "None"}, number)
        if line == "break":
            return Instruction("break", {}, number)
        if line == "continue":
            return Instruction("continue", {}, number)
        raise BRXError(f"linha {number}: instrução desconhecida: {line}")

    def _assignment(self, op: str, body: str, number: int) -> Instruction:
        if "=" not in body:
            raise BRXError(f"linha {number}: atribuição precisa de '='")
        name, expression = (part.strip() for part in body.split("=", 1))
        if not name.isidentifier():
            raise BRXError(f"linha {number}: nome inválido: {name!r}")
        if not expression:
            raise BRXError(f"linha {number}: expressão vazia")
        return Instruction(op, {"name": name, "value": expression}, number)


class _Signal(Exception):
    def __init__(self, value: Any = None): self.value = value
class _Return(_Signal): pass
class _Break(_Signal): pass
class _Continue(_Signal): pass


class SafeEvaluator(ast.NodeVisitor):
    def __init__(self, variables: dict[str, Any], functions: dict[str, Any]):
        self.variables, self.functions = variables, functions

    def evaluate(self, expression: str) -> Any:
        try:
            return self.visit(ast.parse(expression, mode="eval").body)
        except SyntaxError as exc:
            raise BRXError(f"expressão inválida: {expression}") from exc

    def visit_Constant(self, node):
        if isinstance(node.value, (int, float, str, bool, type(None))): return node.value
        raise BRXError("constante não suportada")
    def visit_Name(self, node):
        if node.id not in self.variables: raise BRXError(f"variável não definida: {node.id}")
        return self.variables[node.id]
    def visit_BinOp(self, node):
        left, right = self.visit(node.left), self.visit(node.right)
        if isinstance(node.op, ast.Add) and (isinstance(left, str) or isinstance(right, str)):
            return str(left) + str(right)
        ops = {ast.Add: lambda a,b:a+b, ast.Sub:lambda a,b:a-b, ast.Mult:lambda a,b:a*b,
               ast.Div:lambda a,b:a/b, ast.FloorDiv:lambda a,b:a//b, ast.Mod:lambda a,b:a%b}
        handler = ops.get(type(node.op))
        if handler is None: raise BRXError("operador não suportado")
        try: return handler(left, right)
        except Exception as exc: raise BRXError(f"falha na operação: {exc}") from exc
    def visit_UnaryOp(self, node):
        value = self.visit(node.operand)
        if isinstance(node.op, ast.USub): return -value
        if isinstance(node.op, ast.UAdd): return +value
        if isinstance(node.op, ast.Not): return not value
        raise BRXError("operador unário não suportado")
    def visit_Compare(self, node):
        left = self.visit(node.left)
        ops = {ast.Eq:lambda a,b:a==b, ast.NotEq:lambda a,b:a!=b, ast.Lt:lambda a,b:a<b,
               ast.LtE:lambda a,b:a<=b, ast.Gt:lambda a,b:a>b, ast.GtE:lambda a,b:a>=b}
        for operator, comparator in zip(node.ops, node.comparators):
            right = self.visit(comparator); handler = ops.get(type(operator))
            if handler is None or not handler(left, right): return False
            left = right
        return True
    def visit_BoolOp(self, node):
        if isinstance(node.op, ast.And):
            for value in node.values:
                result = self.visit(value)
                if not result: return result
            return result
        if isinstance(node.op, ast.Or):
            for value in node.values:
                result = self.visit(value)
                if result: return result
            return result
        raise BRXError("operador lógico não suportado")
    def visit_Call(self, node):
        if not isinstance(node.func, ast.Name) or node.keywords:
            raise BRXError("chamada não permitida")
        fn = self.functions.get(node.func.id)
        if fn is None: raise BRXError(f"função não definida: {node.func.id}")
        return fn(*[self.visit(arg) for arg in node.args])
    def generic_visit(self, node):
        raise BRXError(f"expressão não permitida: {type(node).__name__}")


class Runtime:
    def __init__(self, *, max_steps: int = 100_000):
        self.max_steps = max_steps
        self.steps = 0
        self.output: list[str] = []
        self.functions: dict[str, Any] = {}

    def execute(self, module: Module) -> dict[str, Any]:
        variables: dict[str, Any] = {}
        self.output, self.functions, self.steps = [], {}, 0
        try:
            self._block(module.instructions, variables)
            result = None
        except _Return as signal:
            result = signal.value
        return {"output": self.output, "variables": variables, "return": result}

    def _tick(self, line: int):
        self.steps += 1
        if self.steps > self.max_steps:
            raise BRXError(f"linha {line}: limite de execução excedido")

    def _block(self, instructions: list[Instruction], variables: dict[str, Any]):
        evaluator = SafeEvaluator(variables, self.functions)
        for instruction in instructions:
            self._tick(instruction.line)
            op, args = instruction.op, instruction.args
            if op == "let":
                name = args["name"]
                if name in variables: raise BRXError(f"linha {instruction.line}: variável já existe: {name}")
                variables[name] = evaluator.evaluate(args["value"])
            elif op == "set":
                name = args["name"]
                if name not in variables: raise BRXError(f"linha {instruction.line}: variável não definida: {name}")
                variables[name] = evaluator.evaluate(args["value"])
            elif op == "print": self.output.append(str(evaluator.evaluate(args["value"])))
            elif op == "return": raise _Return(evaluator.evaluate(args["value"]))
            elif op == "break": raise _Break()
            elif op == "continue": raise _Continue()
            elif op == "if": self._block(args["then"] if evaluator.evaluate(args["condition"]) else args["else"], variables)
            elif op == "while":
                while evaluator.evaluate(args["condition"]):
                    try: self._block(args["body"], variables)
                    except _Continue: continue
                    except _Break: break
            elif op == "loop":
                start, finish = int(evaluator.evaluate(args["start"])), int(evaluator.evaluate(args["finish"]))
                step = 1 if args["direction"] == "to" else -1
                stop = finish + step
                for value in range(start, stop, step):
                    variables[args["name"]] = value
                    try: self._block(args["body"], variables)
                    except _Continue: continue
                    except _Break: break
            elif op == "function":
                name, params, body = args["name"], args["params"], args["body"]
                if name in self.functions: raise BRXError(f"linha {instruction.line}: função já existe: {name}")
                def function(*values, _params=params, _body=body, _line=instruction.line):
                    if len(values) != len(_params): raise BRXError(f"linha {_line}: quantidade inválida de argumentos")
                    local = dict(zip(_params, values))
                    try: self._block(_body, local)
                    except _Return as signal: return signal.value
                    return None
                self.functions[name] = function
            else: raise BRXError(f"operação IR desconhecida: {op}")


def compile_source(source: str, module_name: str = "main") -> Module:
    return Parser().parse(source, module_name)


def run_source(source: str, module_name: str = "main") -> dict[str, Any]:
    return Runtime().execute(compile_source(source, module_name))
