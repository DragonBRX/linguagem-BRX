# BRX — Camada Externa (API Pública)

> **O que o programador vê e escreve.**

Esta pasta não contém código executável — contém a **documentação da API pública**
que o programador BRX utiliza.

## As 7 Camadas Externas

### BRX[E] — EASY (Lógica)
```
var nome:txt = "Dragon"
if condicao
  out "Sim"
else
  out "Nao"
end
loop i:0 to 10
  out i
end
func soma(a:num, b:num)
  return a + b
end
```

### BRX[V] — VISUAL (Gráficos)
```
win
  sz 800x600
  tt "Minha Janela"
  bg "#1a1a2e"
  txt "Hello" x:100 y:50 sz:24 col:"#FFFFFF"
  btn "Clique" x:100 y:100 w:80 h:30
    clk -> minha_funcao
  end
end
```

### BRX[R] — RUNTIME (Game Loop)
```
loop while win.open
  upd
  drw
  wait 16
end
```

### BRX[B] — BINARY (Compilação)
```
bin
  opt speed
  tgt linux64
end
```

### BRX[H] — HARDWARE (Metal)
```
hw
  mem alloc 1024 -> buf
  reg set r0 1
end
```

### BRX[S] — SANDBOX (Isolamento)
```
sbx
  lim mem 64
  lim time 5000
  load "plugin.brx"
end
```

### BRX[T] — TRANSLATE (Compatibilidade)
```
tr
  src "programa.exe"
  map syscall
end
```

## Por que Separar?

A camada externa é **só a interface**. A implementação real está em `src/internal/`.
Isso permite:

- Mudar o motor interno sem quebrar código dos usuários
- Portar para novos SOs mantendo a mesma sintaxe .brx
- Documentar claramente o que é público vs. privado
