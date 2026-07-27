import unittest

from brxbase import BRXError, compile_source, run_source


class BRXBaseTests(unittest.TestCase):
    def test_compila_para_ir_neutra(self):
        module = compile_source('let x = 10\nout x + 2\nreturn x')
        data = module.to_dict()
        self.assertEqual(data['format'], 'BRX-IR')
        self.assertEqual(data['version'], 1)
        self.assertEqual([item['op'] for item in data['instructions']], ['let', 'print', 'return'])

    def test_executa_variaveis_e_expressoes(self):
        result = run_source('let x = 10\nset x = x * 3\nout x\nreturn x + 1')
        self.assertEqual(result['output'], ['30'])
        self.assertEqual(result['variables']['x'], 30)
        self.assertEqual(result['return'], 31)

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


if __name__ == '__main__':
    unittest.main()
