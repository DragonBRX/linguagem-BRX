# Linguagem BRX

BRX é uma linguagem-base experimental construída com apoio de múltiplas linguagens. A implementação atual usa Python como frontend e runtime de referência, enquanto a BRX-IR funciona como contrato neutro para futuras implementações em C, Rust, Assembly e outras linguagens.

## Estrutura

```text
brxbase/     núcleo, parser, BRX-IR e runtime de referência
docs/        especificação e arquitetura da linguagem
exemplos/    programas BRX executáveis
tests/       testes automatizados
```

## Uso

```bash
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --emit-ir
python3 -m brxbase.cli exemplos/base_multilinguagem.brx --run
python3 -m unittest discover -s tests -v
```

## Direção

A linguagem não depende de uma única tecnologia. Cada frontend deverá converter sua linguagem de origem para BRX-IR, e runtimes compatíveis deverão executar essa representação com o mesmo comportamento.

A implementação antiga baseada exclusivamente em Assembly foi removida da árvore principal. Ela continua disponível no histórico do Git.
