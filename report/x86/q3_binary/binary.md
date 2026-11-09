# 課題3(4)(5) binary.md

すべて `nasm -O0 -f elf64` でアセンブルし `objdump -d -Mintel` で実際に逆アセンブルして確認した。

## (4) `rax` に `0xCA` を格納するバイナリ

### 5バイト版（32bitレジスタ eax 経由、上位32bitは自動ゼロ拡張）

```nasm
mov eax, 0xca
```

```
$ objdump -d -Mintel
0:	b8 ca 00 00 00       	mov    eax,0xca
```

| 機械語Hex | 内訳 |
|---|---|
| `b8 ca 00 00 00` | オペコード`b8`(1B) + 32bit即値`ca 00 00 00`(4B) = 計5バイト |

実行後 `rax = 0x00000000000000ca`（32bit書き込みによる上位32bitゼロ拡張のため）。

### 10バイト版（64bitレジスタ rax へ直接 movabs）

```nasm
mov rax, 0xca
```

```
$ objdump -d -Mintel
0:	48 b8 ca 00 00 00 00 00 00 00 	movabs rax,0xca
```

| 機械語Hex | 内訳 |
|---|---|
| `48 b8 ca 00 00 00 00 00 00 00` | REX.W(`48`,1B) + オペコード`b8`(1B) + 64bit即値(8B) = 計10バイト |

## (5) `rax` に `0xCAFEBABE` を格納するバイナリ

### 5バイト版（32bitレジスタ eax 経由）

```nasm
mov eax, 0xcafebabe
```

```
$ objdump -d -Mintel
0:	b8 be ba fe ca       	mov    eax,0xcafebabe
```

| 機械語Hex | 内訳 |
|---|---|
| `b8 be ba fe ca` | オペコード`b8`(1B) + 32bit即値`be ba fe ca`(リトルエンディアン, 4B) = 計5バイト |

実行後 `rax = 0x00000000cafebabe`。

### 10バイト版（64bitレジスタ rax へ直接 movabs）

```nasm
mov rax, 0xcafebabe
```

```
$ objdump -d -Mintel
0:	48 b8 be ba fe ca 00 00 00 00 	movabs rax,0xcafebabe
```

| 機械語Hex | 内訳 |
|---|---|
| `48 b8 be ba fe ca 00 00 00 00` | REX.W(`48`) + オペコード`b8` + 64bit即値(8B、上位4バイトは`00`でゼロ拡張) = 計10バイト |

## 符号拡張命令の注意点

`0xCAFEBABE` は32bit値として見ると最上位ビット（bit31）が `1`（`0xCA` = `1100_1010`）であり、
符号付き32bit整数として解釈すると負の値になる。

x86-64 には「64bitレジスタに32bit即値を**符号拡張**してロードする」命令
（`REX.W + C7 /0 id` : `MOV r/m64, imm32`）も存在する。もしこの命令を使って
`0xCAFEBABE` をロードしてしまうと、実際に試した通り以下のようになる。

```nasm
; REX.W C7 /0 形式で 0xCAFEBABE をロードした場合の生バイト列
db 0x48, 0xc7, 0xc0, 0xbe, 0xba, 0xfe, 0xca
```
```
$ objdump -d -Mintel
0:	48 c7 c0 be ba fe ca 	mov    rax,0xffffffffcafebabe
```

このように、意図していた `0x00000000cafebabe` ではなく
**符号拡張された `0xffffffffcafebabe`** が `rax` に格納されてしまう（7バイト）。

NASM は `mov eax, 0xcafebabe`（ゼロ拡張の5バイト版）や `mov rax, 0xcafebabe`（`movabs`による
ゼロ拡張の10バイト版）を自動的に選択し、この危険な符号拡張命令（`C7 /0`）を明示的に
要求しない限り使用しない。上位ビットが1であるような大きな32bit即値を64bitレジスタに
格納する際は、「ゼロ拡張」なのか「符号拡張」なのかで結果が全く異なる値になる点に
注意が必要である。
