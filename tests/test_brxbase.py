import unittest

from brxbase import BRXError, compile_source, run_source


class BRXBaseTests(unittest.TestCase):
    def test_compila_para_ir_neutra_v2(self):
        module = compile_source('let x = 10\nout x + 2\nreturn x')
        data = module.to_dict()
        self.assertEqual(data['format'], 'BRX-IR')
        self.assertEqual(data['version'], 2)
        self.assertEqual([item['op'] for item in data['instructions']], ['let', 'print', 'return'])

    def test_executa_variaveis_e_expressoes(self):
        result = run_source('let x = 10\nset x = x * 3\nout x\nreturn x + 1')
        self.assertEqual(result['output'], ['30'])
        self.assertEqual(result['variables']['x'], 30)
        self.assertEqual(result['return'], 31)

    def test_if_else(self):
        source = '''
let x = 7
if x % 2 == 0
    out "par"
else
    out "impar"
end
'''
        self.assertEqual(run_source(source)['output'], ['impar'])

    def test_loop_break_continue(self):
        source = '''
let soma = 0
loop i:1 to 10
    if i == 3
        continue
    end
    if i == 6
        break
    end
    set soma = soma + i
end
out soma
'''
        result = run_source(source)
        self.assertEqual(result['output'], ['12'])

    def test_while(self):
        source = '''
let x = 0
while x < 3
    set x = x + 1
end
return x
'''
        self.assertEqual(run_source(source)['return'], 3)

    def test_loop_decrescente(self):
        result = run_source('loop i:3 downto 1\nout i\nend')
        self.assertEqual(result['output'], ['3', '2', '1'])

    def test_funcao_com_retorno(self):
        source = '''
fn dobro(valor)
    return valor * 2
end
let resultado = dobro(21)
out resultado
return dobro(resultado)
'''
        result = run_source(source)
        self.assertEqual(result['output'], ['42'])
        self.assertEqual(result['return'], 84)

    def test_funcao_com_escopo_local(self):
        source = '''
fn soma(a, b)
    let total = a + b
    return total
end
let total = 100
return soma(2, 3)
'''
        result = run_source(source)
        self.assertEqual(result['return'], 5)
        self.assertEqual(result['variables']['total'], 100)

    def test_strings(self):
        result = run_source('let nome = "BRX"\nout "Olá " + nome')
        self.assertEqual(result['output'], ['Olá BRX'])

    def test_rejeita_redeclaracao(self):
        with self.assertRaises(BRXError):
            run_source('let x = 1\nlet x = 2')

    def test_rejeita_set_sem_declaracao(self):
        with self.assertRaises(BRXError):
            run_source('set x = 2')

    def test_rejeita_codigo_python_arbitrario(self):
        with self.assertRaises(BRXError):
            run_source('out __import__("os")')

    def test_rejeita_bloco_sem_end(self):
        with self.assertRaises(BRXError):
            compile_source('if True\nout 1')

    def test_limite_de_execucao(self):
        from brxbase.core import Runtime
        module = compile_source('while True\nout 1\nend')
        with self.assertRaises(BRXError):
            Runtime(max_steps=10).execute(module)


if __name__ == '__main__':
    unittest.main()
