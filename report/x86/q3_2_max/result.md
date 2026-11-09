# 課題3(2) result.md

## 1. プログラムコード (max.asm)

```nasm
global _start
section .text
_start:
    mov rax, 10
    mov rbx, 20

    cmp rax, rbx
    jge rax_is_bigger

    mov rdi, rbx
    jmp do_exit

rax_is_bigger:
    mov rdi, rax

do_exit:
    mov rax, 60
    syscall
```

## 2. 説明

`rax=10`, `rbx=20` を `cmp`+`jge` で比較し、`rax >= rbx` なら `rax` を、そうでなければ `rbx` を
`rdi` に格納してから `sys_exit`（`rax=60`）を呼び出す。終了コードとして大きい方の値が
OSに返される。

ビルド:
```
nasm -O0 -f elf64 -o max.o max.asm
ld -o max max.o
```

## 3. 実行ログ

### 逆アセンブル結果
```
$ objdump -d -Mintel max

0000000000401000 <_start>:
  401000:	48 b8 0a 00 00 00 00 	movabs rax,0xa
  401007:	00 00 00
  40100a:	48 bb 14 00 00 00 00 	movabs rbx,0x14
  401011:	00 00 00
  401014:	48 39 d8             	cmp    rax,rbx
  401017:	7d 08                	jge    401021 <rax_is_bigger>
  401019:	48 89 df             	mov    rdi,rbx
  40101c:	e9 03 00 00 00       	jmp    401024 <do_exit>

0000000000401021 <rax_is_bigger>:
  401021:	48 89 c7             	mov    rdi,rax

0000000000401024 <do_exit>:
  401024:	48 b8 3c 00 00 00 00 	movabs rax,0x3c
  40102b:	00 00 00
  40102e:	0f 05                	syscall
```

### 実行結果（終了コード確認）
```
$ ./max; echo $?
20
```

`rax=10, rbx=20` のうち大きい方である `20` が終了コードとして返ってきており、
期待通りの動作をしていることが確認できる。

## 4. バイナリ対応表

| アドレス | 機械語Hex | アセンブリ命令 | 説明 |
|---|---|---|---|
| 401000 | `48 b8 0a 00 00 00 00 00 00 00` | `mov rax, 10` | rax=10 |
| 40100a | `48 bb 14 00 00 00 00 00 00 00` | `mov rbx, 20` | rbx=20 |
| 401014 | `48 39 d8` | `cmp rax, rbx` | rax-rbxを計算しフラグのみ更新 |
| 401017 | `7d 08` | `jge rax_is_bigger` | rax>=rbxならジャンプ(近距離相対分岐, 2バイト) |
| 401019 | `48 89 df` | `mov rdi, rbx` | rbxが大きい場合の代入 |
| 40101c | `e9 03 00 00 00` | `jmp do_exit` | 近距離分岐でdo_exitへ |
| 401021 | `48 89 c7` | `mov rdi, rax` | raxが大きい(以上)場合の代入 |
| 401024 | `48 b8 3c 00 00 00 00 00 00 00` | `mov rax, 60` | sys_exit番号 |
| 40102e | `0f 05` | `syscall` | システムコール呼び出し |
