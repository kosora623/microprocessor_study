# 課題3(1) result.md

## 1. プログラムコード (swap.asm)

```nasm
global _start
section .text
_start:
    mov rax, 10
    mov rbx, 20
    xchg rax, rbx

    mov rdi, 0
    mov rax, 60
    syscall
```

## 2. 説明

`rax` に 10、`rbx` に 20 を格納した後、`xchg rax, rbx` 命令一発で両レジスタの内容を交換する。
`xchg` はテンポラリレジスタを使わずにレジスタ間の値を直接入れ替えられる x86 特有の命令である。
交換後は `sys_exit(0)` でプロセスを終了する。

ビルド:
```
nasm -O0 -f elf64 -o swap.o swap.asm
ld -o swap swap.o
```

## 3. 実行ログ

### 逆アセンブル結果
```
$ objdump -d -Mintel swap

0000000000401000 <_start>:
  401000:	48 b8 0a 00 00 00 00 	movabs rax,0xa
  401007:	00 00 00
  40100a:	48 bb 14 00 00 00 00 	movabs rbx,0x14
  401011:	00 00 00
  401014:	48 93                	xchg   rbx,rax
  401016:	48 bf 00 00 00 00 00 	movabs rdi,0x0
  40101d:	00 00 00
  401020:	48 b8 3c 00 00 00 00 	movabs rax,0x3c
  401027:	00 00 00
  40102a:	0f 05                	syscall
```

### GDB (-batch) によるレジスタ変化ログ

GDBの対話モードはハングの危険があるため、CLAUDE.mdのルールに従い `-batch` と
事前に作成した `.gdb` スクリプト (`swap.gdb`) を使用した。

`swap.gdb`:
```gdb
break _start
run
stepi 2
printf "=== BEFORE xchg (expect rax=10, rbx=20) ===\n"
info registers rax rbx
stepi 1
printf "=== AFTER xchg (expect rax=20, rbx=10) ===\n"
info registers rax rbx
quit
```

実行コマンド: `gdb -batch -x swap.gdb ./swap`

```
Breakpoint 1 at 0x401000

Breakpoint 1, 0x0000000000401000 in _start ()
0x0000000000401014 in _start ()
=== BEFORE xchg (expect rax=10, rbx=20) ===
rax            0xa                 10
rbx            0x14                20
0x0000000000401016 in _start ()
=== AFTER xchg (expect rax=20, rbx=10) ===
rax            0x14                20
rbx            0xa                 10
```

`xchg` 実行前は `rax=10, rbx=20`、実行後は `rax=20, rbx=10` となり、
両レジスタの値が正しく交換されたことが確認できる。

## 4. バイナリ対応表

| アドレス | 機械語Hex | アセンブリ命令 | 説明 |
|---|---|---|---|
| 401000 | `48 b8 0a 00 00 00 00 00 00 00` | `mov rax, 10` | movabs相当。rax=10 |
| 40100a | `48 bb 14 00 00 00 00 00 00 00` | `mov rbx, 20` | movabs相当。rbx=20 |
| 401014 | `48 93` | `xchg rax, rbx` | REX.W(48) + オペコード(93, `xchg r64,rAX`の短縮形)。2バイトでレジスタ交換を実現 |
| 401016 | `48 bf 00 00 00 00 00 00 00 00` | `mov rdi, 0` | 終了コード0を設定 |
| 401020 | `48 b8 3c 00 00 00 00 00 00 00` | `mov rax, 60` | sys_exit番号(60) |
| 40102a | `0f 05` | `syscall` | システムコール呼び出し(2バイト) |
