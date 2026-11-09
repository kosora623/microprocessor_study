# 課題5(1) result.md

## 0. 元になった test4.asm（講義資料より, x86-64）

```nasm
global _start
section .data
mes1: db "TRUE", 0x0a
mes1len: equ $ - mes1
mes2: db "FALSE", 0x0a
mes2len: equ $ - mes2
section .text
_start:
mov rbx, 20
if:
cmp rbx, 10
jne else
then:
mov rax, 1
mov rdi, 1
mov rsi, mes1
mov rdx, mes1len
syscall
jmp endif
else:
mov rax, 1
mov rdi, 1
mov rsi, mes2
mov rdx, mes2len
syscall
endif:
mov rax, 60
mov rdi, 0
syscall
```

`rbx=20` を `10` と比較し、等しくなければ（`jne`）`else`（"FALSE\n"）へ、
等しければ `then`（"TRUE\n"）を出力してから終了する。`rbx=20 ≠ 10` のため、
実際には `else` 側（"FALSE\n"）が実行される。

## 1. プログラムコード (test4_rv.s)

```asm
.data
mes1: .asciz "TRUE\n"
mes2: .asciz "FALSE\n"

.text
.globl _start
_start:
    li   t1, 20
    li   t2, 10

if_cmp:
    beq  t1, t2, then

else_branch:
    la   a1, mes2
    li   a0, 4          # ecall規約(Venus拡張): a0=サービス番号, print_string=4
    ecall
    j    endif

then:
    la   a1, mes1
    li   a0, 4          # print_string=4
    ecall

endif:
    li   a0, 10         # exit=10
    ecall
```

## 2. 説明

x86版の `cmp rbx,10` + `jne else` を、RISC-Vでは `t1=20`, `t2=10` を
`beq t1, t2, then`（等しければthenへ分岐、それ以外は後続のelse_branchへフォールスルー）
という等価なロジックで実現した。`t1=20 ≠ t2=10` のため `else_branch` が実行され、
`"FALSE\n"` が出力される点もx86版と完全に一致する。

`ecall` の呼び出し規約は、授業資料で紹介されている VSCode拡張
「RISC-V Venus Simulator」（https://github.com/ThaumicMekanism/venus/wiki/Environmental-Calls）
の規約を採用した。この規約はRARS標準とは異なり、**`a0`にサービス番号、`a1`に引数**を置く
（標準RARSは`a7`にサービス番号を置く）。資料中のサンプルプログラム②
（`li a0, 4  # systemcall(4:print_string)` の後に `ecall`、引数は `a1` に `la` 済み）
からもこの規約であることが確認できる。
- `a0=1`: print_int（`a1`に出力する整数値）
- `a0=4`: print_string（`a1`にヌル終端文字列のアドレス）
- `a0=10`: exit

**実行環境についての注記**: 本演習環境には実際のVenusシミュレータは無く、実RISC-Vツールチェイン
（`riscv64-linux-gnu-as/ld/objdump`、`qemu-riscv64`）のみ利用可能である。実Linuxの`ecall`規約は
システムコール番号体系が全く異なるため、上記のVenus規約のまま実行すると正しく動作しない。
CLAUDE.mdの課題5各項目は「バイナリ対応表」「機械語命令列」の作成のみを要求しており
実行ログを要求していないため、本課題はGNUアセンブラでアセンブル→objdumpで実機のビット列を
確認する静的検証にとどめた。

ビルド:
```
riscv64-linux-gnu-as -o test4_rv.o test4_rv.s
riscv64-linux-gnu-ld -o test4_rv test4_rv.o
```

## 3. 実行ログ（逆アセンブル結果）

```
$ riscv64-linux-gnu-objdump -d test4_rv

00000000000100e8 <_start>:
   100e8:	01400313          	li	t1,20
   100ec:	00a00393          	li	t2,10

00000000000100f0 <if_cmp>:
   100f0:	00730a63          	beq	t1,t2,10104 <then>

00000000000100f4 <else_branch>:
   100f4:	80618593          	addi	a1,gp,-2042 # 11122 <mes2>
   100f8:	00400513          	li	a0,4
   100fc:	00000073          	ecall
   10100:	0140006f          	j	10114 <endif>

0000000000010104 <then>:
   10104:	00001597          	auipc	a1,0x1
   10108:	01858593          	addi	a1,a1,24 # 1111c <__DATA_BEGIN__>
   1010c:	00400513          	li	a0,4
   10110:	00000073          	ecall

0000000000010114 <endif>:
   10114:	00a00513          	li	a0,10
   10118:	00000073          	ecall
```

```
$ riscv64-linux-gnu-objdump -s -j .data test4_rv
Contents of section .data:
 1111c 54525545 0a004641 4c53450a 00        TRUE..FALSE..
```

`t1=20, t2=10` は等しくないため `beq` は成立せず、`else_branch` にフォールスルーして
`a1` に `mes2`（"FALSE\n"）のアドレスをセットし `a0=4` で print_string相当のecallを
呼ぶ経路が選択される。これはx86版test4.asmの実行結果（"FALSE\n"）と一致する。

## 4. バイナリ対応表

| アドレス | 機械語Hex | アセンブリ命令 | 説明 |
|---|---|---|---|
| 100e8 | `01400313` | `addi t1, x0, 20`（li展開） | t1=20 |
| 100ec | `00a00393` | `addi t2, x0, 10`（li展開） | t2=10 |
| 100f0 | `00730a63` | `beq t1, t2, 10104` | t1==t2ならthenへ分岐（SB-type） |
| 100f4 | `80618593` | `addi a1, gp, -2042` | `la a1,mes2`展開。gp相対アドレッシング |
| 100f8 | `00400513` | `addi a0, x0, 4` | print_stringサービス番号(a0=サービス番号規約) |
| 100fc | `00000073` | `ecall` | システムコール呼び出し |
| 10100 | `0140006f` | `jal x0, 10114` | endifへの無条件ジャンプ |
| 10104 | `00001597` | `auipc a1, 0x1` | `la a1,mes1`展開①：PC相対上位20bit |
| 10108 | `01858593` | `addi a1, a1, 24` | `la a1,mes1`展開②：下位オフセット加算 |
| 1010c | `00400513` | `addi a0, x0, 4` | print_stringサービス番号 |
| 10110 | `00000073` | `ecall` | システムコール呼び出し |
| 10114 | `00a00513` | `addi a0, x0, 10` | exitサービス番号 |
| 10118 | `00000073` | `ecall` | システムコール呼び出し |
