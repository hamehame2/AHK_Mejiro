# AHK_Mejiro
個人用にメジロ式のAHK版バックアップと辞書更新時の改変用

稚拙ですが、暫定版です。
かなの直接入力となっており、ローマ字入力とタイピングモードは実装ですのでタイピングゲームの期待はしないでください。

比較的最初の方のシフト選択系統が残ったままです。ござい関係と、強化版の　です系統　はまだ未実装だったはずです（tn*自体はつけてました）。


メジロ式はじーびす様が開発された速記入力システムです。
https://github.com/JEEBIS27/Plover_Mejiro?tab=GPL-3.0-1-ov-file

親指キーに関してはn(n)c(t)v(k)と n(k)m(t),(n)をデフォルトで指定しています。
各自下記を改変して使用ください。

;----------------------------------
; QWERTY → メジロ論理キー
;----------------------------------
global MejiroKeyDef := Map()

AddKey("q", "L", "hyphen", "#")
AddKey("w", "L", "conso",  "T")
AddKey("e", "L", "vowel",  "Y")
AddKey("r", "L", "vowel",  "I")
AddKey("t", "L", "vowel",  "U")

AddKey("a", "L", "conso",  "S")
AddKey("s", "L", "conso",  "K")
AddKey("d", "L", "conso",  "N")
AddKey("f", "L", "vowel",  "A")
AddKey("g", "L", "vowel",  "U")

AddKey("z", "L", "hyphen", "#")
AddKey("c", "L", "particle", "n")
AddKey("v", "L", "particle", "t")
AddKey("b", "L", "particle", "k")

AddKey("y", "R", "vowel",  "U")
AddKey("u", "R", "vowel",  "I")
AddKey("i", "R", "vowel",  "Y")
AddKey("o", "R", "conso",  "T")
AddKey("p", "R", "star",   "*")
AddKey(":", "R", "star",   "*")
AddKey("@", "R", "star",   "*")

AddKey("h", "R", "vowel",  "U")
AddKey("j", "R", "vowel",  "A")
AddKey("k", "R", "conso",  "N")
AddKey("l", "R", "conso",  "K")
AddKey(";", "R", "conso",  "S")

AddKey("/", "R", "star",   "*")
AddKey("n", "R", "particle", "k")
AddKey("m", "R", "particle", "t")
AddKey(",", "R", "particle", "n")
