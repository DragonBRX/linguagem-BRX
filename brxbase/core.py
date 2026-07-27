"""Núcleo experimental da linguagem-base BRX.

Converte uma sintaxe BRX pequena para uma IR neutra e executável. A IR foi
pensada para receber, no futuro, frontends escritos em outras linguagens sem
acoplar a linguagem BRX a um único compilador.
"""

from __future__ import annotations

from dataclasses import dataclass, asdict
from typing import Any
import ast
import json


class BRXError(Exception):
    """Erro de análise, validação ou execução BRX."""


@dataclass(slots=True)
class Instruction:
    op: str
    args: dict[str, Any]
    line: int

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


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
    """Parser de linha simples para o primeiro subconjunto BRX-IR."""

    def parse(self, source: str, module_name: str = "main") -> Module:
        instructions: list[Instruction] = []
        for number, raw in enumerate(source.splitlines(), start=1):
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "#" in line:
                line = line.split("#", 1)[0].rstrip()
            instructions.append(self._parse_line(line, number))
        return Module(module_name, 1, instructions)

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
        raise BRXError(f"linha {number}: instrução desconhecida: {line}")

    def _assignment(self, op: str, body: str, number: int) -> Instruction:
        if "=" not in body:
            raise BRXError(f"linha {number}: atribuição precisa de '='")
        name, expression = body.split("=", 1)
        name = name.strip()
        expression = expression.strip()
        if not name.isidentifier():
            raise BRXError(f"linha {number}: nome inválido: {name!r}")
        if not expression:
            raise BRXError(f"linha {number}: expressão vazia")
        return Instruction(op, {"name": name, "value": expression}, number)


class SafeEvaluator(ast.NodeVisitor):
    """Avaliador pequeno e determinístico para expressões BRX."""

    def __init__(self, variables: dict[str, Any]):
        self.variables = variables

    def evaluate(self, expression: str) -> Any:
        try:
            tree = ast.parse(expression, mode="eval")
        except SyntaxError as exc:
            raise BRXError(f"expressão inválida: {expression}") from exc
        return self.visit(tree.body)

    def visit_Constant(self, node: ast.Constant) -> Any:
        if isinstance(node.value, (int, float, str, bool, type(None))):
            return node.value
        raise BRXError("constante não suportada")

    def visit_Name(self, node: ast.Name) -> Any:
        if node.id not in self.variables:
            raise BRXError(f"variável não definida: {node.id}")
        return self.variables[node.id]

    def visit_BinOp(self, node: ast.BinOp) -> Any:
        left = self.visit(node.left)
        right = self.visit(node.right)
        operations = {
            ast.Add: lambda a, b: a + b,
            ast.Sub: lambda a, b: a - b,
            ast.Mult: lambda a, b: a * b,
            ast.Div: lambda a, b: a / b,
            ast.FloorDiv: lambda a, b: a // b,
            ast.Mod: lambda a, b: a % b,
        }
        handler = operations.get(type(node.op))
        if handler is None:
            raise BRXError("operador não suportado")
        try:
            return handler(left, right)
        except Exception as exc:
            raise BRXError(f"falha na operação: {exc}") from exc

    def visit_UnaryOp(self, node: ast.UnaryOp) -> Any:
        value = self.visit(node.operand)
        if isinstance(node.op, ast.USub):
            return -value
        if isinstance(node.op, ast.UAdd):
            return +value
        if isinstance(node.op, ast.Not):
            return not value
        raise BRXError("operador unário não suportado")

    def visit_Compare(self, node: ast.Compare) -> bool:
        left = self.visit(node.left)
        operators = {
            ast.Eq: lambda a, b: a == b,
            ast.NotEq: lambda a, b: a != b,
            ast.Lt: lambda a, b: a < b,
            ast.LtE: lambda a, b: a <= b,
            ast.Gt: lambda a, b: a > b,
            ast.GtE: lambda a, b: a >= b,
        }
        for operator, comparator in zip(node.ops, node.comparators):
            right = self.visit(comparator)
            handler = operators.get(type(operator))
            if handler is None or not handler(left, right):
                return False
            left = right
        return True

    def visit_BoolOp(self, node: ast.BoolOp) -> bool:
        values = [bool(self.visit(value)) for value in node.values]
        if isinstance(node.op, ast.And):
            return all(values)
        if isinstance(node.op, ast.Or):
            return any(values)
        raise BRXError("operador lógico não suportado")

    def generic_visit(self, node: ast.AST) -> Any:
        raise BRXError(f"expressão não permitida: {type(node).__name__}")


class Runtime:
    """Executa a IR comum e devolve saída, variáveis e retorno."""

    def execute(self, module: Module) -> dict[str, Any]:
        variables: dict[str, Any] = {}
        output: list[str] = []
        result: Any = None
        evaluator = SafeEvaluator(variables)

        for instruction in module.instructions:
            op = instruction.op
            args = instruction.args
            if op == "let":
                name = args["name"]
                if name in variables:
                    raise BRXError(f"linha {instruction.line}: variável já existe: {name}")
                variables[name] = evaluator.evaluate(args["value"])
            elif op == "set":
                name = args["name"]
                if name not in variables:
                    raise BRXError(f"linha {instruction.line}: variável não definida: {name}")
                variables[name] = evaluator.evaluate(args["value"])
            elif op == "print":
                output.append(str(evaluator.evaluate(args["value"])))
            elif op == "return":
                result = evaluator.evaluate(args["value"])
                break
            else:
                raise BRXError(f"operação IR desconhecida: {op}")

        return {"output": output, "variables": variables, "return": result}


def compile_source(source: str, module_name: str = "main") -> Module:
    return Parser().parse(source, module_name)


def run_source(source: str, module_name: str = "main") -> dict[str, Any]:
    return Runtime().execute(compile_source(source, module_name))
