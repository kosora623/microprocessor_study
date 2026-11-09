# 課題5(3) result.md

## 1. プログラムコード (max.s)

```asm
.text
.globl _start
_start:
    li t1, 10
    li t2, 20

    bge t1, t2, t1_is_bigger

    mv t3, t2
    j  do_exit

t1_is_bigger:
    mv t3, t1

do_exit:
    li a0, 10          # ecall規約(Venus拡張): a0=サービス番号, exit=10
    ecall
```

## 2. 説明

`t1=10`, `t2=20` を `bge t1, t2, ...`（`t1 >= t2` なら分岐）で比較する。
`t1 < t2` の場合は分岐せずに `t3 = t2` を実行し、`t1 >= t2` の場合は `t1_is_bigger` に
分岐して `t3 = t1` を実行する。いずれの場合も最終的に `t3` に大きい方の値が格納される。

`ecall`の呼び出し規約はq5_1のresult.mdに記載したVenus拡張規約（`a0`=サービス番号, `a1`=引数）
に従う。

ビルド:
```
riscv64-linux-gnu-as -o max.o max.s
riscv64-linux-gnu-ld -o max max.o
```

## 3. 実行ログ（逆アセンブル結果）

```
$ riscv64-linux-gnu-objdump -d max

00000000000100b0 <_start>:
   100b0:	00a00313          	li	t1,10
   100b4:	01400393          	li	t2,20
   100b8:	00735663          	bge	t1,t2,100c4 <t1_is_bigger>
   100bc:	00038e13          	mv	t3,t2
   100c0:	0080006f          	j	100c8 <do_exit>

00000000000100c4 <t1_is_bigger>:
   100c4:	00030e13          	mv	t3,t1

00000000000100c8 <do_exit>:
   100c8:	00a00513          	li	a0,10
   100cc:	00000073          	ecall
```

`t1=10, t2=20` では `t1>=t2` が成立しないため分岐せず `t3=t2=20` が実行され、
大きい方である `20` が `t3` に格納されることが命令列から確認できる。

## 4. バイナリ対応表

| アドレス | 機械語Hex | アセンブリ命令 | 説明 |
|---|---|---|---|
| 100b0 | `00a00313` | `addi t1, x0, 10`（li展開） | t1=10 |
| 100b4 | `01400393` | `addi t2, x0, 20`（li展開） | t2=20 |
| 100b8 | `00735663` | `bge t1, t2, 100c4` | t1>=t2ならt1_is_biggerへ分岐（SB-type） |
| 100bc | `00038e13` | `addi t3, t2, 0`（mv展開） | t3 ← t2（t2が大きい場合） |
| 100c0 | `0080006f` | `jal x0, 100c8` | do_exitへの無条件ジャンプ（UJ-type） |
| 100c4 | `00030e13` | `addi t3, t1, 0`（mv展開） | t3 ← t1（t1が大きい場合） |
| 100c8 | `00a00513` | `addi a0, x0, 10` | exitサービス番号(a0=サービス番号規約) |
| 100cc | `00000073` | `ecall` | システムコール呼び出し |
