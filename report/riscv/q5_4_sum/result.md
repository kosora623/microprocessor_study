# 課題5(4) result.md

## 1. プログラムコード (sum.s)

```asm
.text
.globl _start
_start:
    li t0, 0        # sum
    li t1, 1        # counter

sum_loop:
    add  t0, t0, t1
    addi t1, t1, 1
    li   t2, 10
    ble  t1, t2, sum_loop
    # t0 = 55

    mv a1, t0       # print_intに渡す値
    li a0, 1        # ecall規約(Venus拡張): a0=サービス番号, print_int=1
    ecall

    li a0, 10       # exit=10
    ecall
```

## 2. 説明

`t0` を合計（初期値0）、`t1` をカウンタ（初期値1）として、`sum_loop` で
`t0 += t1; t1++` を繰り返す。継続条件は「インクリメント後の `t1` が10以下」（`ble t1, t2, ...`、
`t2=10`）であり、これにより `t1 = 1,2,...,10` の10回分だけ加算が行われ、
最終的に `t0 = 1+2+...+10 = 55` となる。

ループ終了後、合計値を `a1` にコピーし、`a0=1`（print_int サービス）で
`ecall` を呼び出し、最後に `a0=10`（exit）で終了する。

`ecall` の呼び出し規約は、授業資料で紹介されているVSCode拡張「RISC-V Venus Simulator」
（https://github.com/ThaumicMekanism/venus/wiki/Environmental-Calls）の規約を採用した。
この規約では **`a0`にサービス番号、`a1`に引数** を置く（標準RARSの`a7`=サービス番号とは異なる）。
授業資料のサンプルプログラム②（`li a1, 10` でint値を用意し、`li a0, 1  # systemcall(1:print_int)`
としてから `ecall`）にもこの規約が明記されている。課題文中の「a0=1, a1=55 で ecall（print_int）」
はまさにこの規約通り（`a0=1`=サービス番号, `a1=55`=出力する値）であり、本実装はこれに忠実に従った。

ビルド:
```
riscv64-linux-gnu-as -o sum.o sum.s
riscv64-linux-gnu-ld -o sum sum.o
```

（実行環境の制約はq5_1と同様。本課題もアセンブル・逆アセンブルによる静的なバイナリ対応表
作成にとどめた。）

## 3. 実行ログ（逆アセンブル結果）

```
$ riscv64-linux-gnu-objdump -d sum

00000000000100b0 <_start>:
   100b0:	00000293          	li	t0,0
   100b4:	00100313          	li	t1,1

00000000000100b8 <sum_loop>:
   100b8:	006282b3          	add	t0,t0,t1
   100bc:	00130313          	addi	t1,t1,1
   100c0:	00a00393          	li	t2,10
   100c4:	fe63dae3          	bge	t2,t1,100b8 <sum_loop>
   100c8:	00028593          	mv	a1,t0
   100cc:	00100513          	li	a0,1
   100d0:	00000073          	ecall
   100d4:	00a00513          	li	a0,10
   100d8:	00000073          	ecall
```

RISC-Vには `ble`（以下かどうかの分岐）という実機械語命令は存在せず、擬似命令
`ble rs1, rs2, label` は「オペランドを入れ替えた `bge rs2, rs1, label`」として
展開される。逆アセンブル結果でも `ble t1, t2, sum_loop` が `bge t2, t1, sum_loop` として
表示されており、これが実際の仕組みであることが確認できる。

## 4. バイナリ対応表

| アドレス | 機械語Hex | アセンブリ命令 | 説明 |
|---|---|---|---|
| 100b0 | `00000293` | `addi t0, x0, 0`（li展開） | 合計の初期化 |
| 100b4 | `00100313` | `addi t1, x0, 1`（li展開） | カウンタの初期化 |
| 100b8 | `006282b3` | `add t0, t0, t1` | 合計にカウンタを加算（ループ先頭） |
| 100bc | `00130313` | `addi t1, t1, 1` | カウンタをインクリメント |
| 100c0 | `00a00393` | `addi t2, x0, 10`（li展開） | 比較用定数10をロード |
| 100c4 | `fe63dae3` | `bge t2, t1, sum_loop`（`ble t1,t2,...`の実体） | t1<=10ならループ継続 |
| 100c8 | `00028593` | `addi a1, t0, 0`（mv展開） | 出力値を a1 にセット |
| 100cc | `00100513` | `addi a0, x0, 1` | print_intサービス番号(a0=サービス番号規約) |
| 100d0 | `00000073` | `ecall` | システムコール呼び出し |
| 100d4 | `00a00513` | `addi a0, x0, 10` | exitサービス番号 |
| 100d8 | `00000073` | `ecall` | システムコール呼び出し |
