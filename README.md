# AHK_Mejiro(windows10, 11で動作確認をしました。)
個人用にメジロ式のAHK版バックアップと辞書更新時の改変用

マイクロソフトアプリセンターでAHKをDLしていただき、.ahkと.ahkincの2つのファイルを同じフォルダ階層に置いて、ahkV2で動かしてください（形式を明示しているため関連付けができていれば.ahkファイルをダブルクリックで動作します）。

稚拙ですが、暫定版です。
かなの直接入力となっており、ローマ字入力とタイピングモードは未実装ですのでタイピングゲームはできないものとお考えください。

比較的最初の方のシフト選択系統が残ったままかもしれません。　ござい関係と、強化版の　です系統　はまだ未実装だったはずです（tn*自体はつけてました）。
基本的な動詞活用やです単体の活用の入力はできますので、基本入力を練習したいかたには必要十分と思います。

##メジロ式はじーびす様が開発された日本語向け速記入力システムです。
https://github.com/JEEBIS27/Plover_Mejiro?tab=GPL-3.0-1-ov-file

レイアウトは下記のような形です（#と*以外は左右対称）。
[https://private-user-images.githubusercontent.com/144299154/505703441-8af6ceb9-730f-4d41-a531-8ac2b05dc7b9.jpeg?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4NzQ3OTQsIm5iZiI6MTc2OTg3NDQ5NCwicGF0aCI6Ii8xNDQyOTkxNTQvNTA1NzAzNDQxLThhZjZjZWI5LTczMGYtNGQ0MS1hNTMxLThhYzJiMDVkYzdiOS5qcGVnP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI2MDEzMSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNjAxMzFUMTU0ODE0WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9YmQxMDE0MDlkZWUxNGY0YjY5NGE5Zjk5ODhiNmEzMTViZmI5YjZkNjJlMTMwYzA0ZTg5NTE3YjAwNTg3M2FmOCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.lVhPpci1nvejz8siLAyKYmkjgaSTt4-cBQXuizmk0Bw](https://private-user-images.githubusercontent.com/144299154/505703441-8af6ceb9-730f-4d41-a531-8ac2b05dc7b9.jpeg?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Njk4NzQ3OTQsIm5iZiI6MTc2OTg3NDQ5NCwicGF0aCI6Ii8xNDQyOTkxNTQvNTA1NzAzNDQxLThhZjZjZWI5LTczMGYtNGQ0MS1hNTMxLThhYzJiMDVkYzdiOS5qcGVnP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI2MDEzMSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNjAxMzFUMTU0ODE0WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9YmQxMDE0MDlkZWUxNGY0YjY5NGE5Zjk5ODhiNmEzMTViZmI5YjZkNjJlMTMwYzA0ZTg5NTE3YjAwNTg3M2FmOCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.lVhPpci1nvejz8siLAyKYmkjgaSTt4-cBQXuizmk0Bw)

御本人様のplover版ではありますがメジロ式の実際の動きの動画はこちらになります。https://youtu.be/_sw6MZ5shTo?t=3757
メジロ式は略語、動詞入力などを除けば左右対称の打ち方で済むため暗記がかなり少ない配列でかつ、一度にたくさんの文字を打てます。
具体的に言うとローマ字入力が１文字あたり平均1.7打鍵必要に対して脅威の平均0.6モーラ以下です。
テレビ用のテロップ(キャプショナー)でステノワードが速記としては有名ですが、数千以上のパターン暗記に支えられており塾に通っての習熟と現実的ではないためメジロ式は画期的なシステムです。
本家のploverは少し実装に難しい部分があるため、pythonではなくAHKで作成をしました。
plover版の開発と公開をしていただき、またAHK版の公開も快く了承いただいたジービス様にはこの場をお借りして感謝を申し上げます。

## 本格的な動作にはNキーロールオーパー可能なキーボードが接続必要です。ノートパソコンなどでは3-4キーの同時押しが限界です。
　特別なことがなければ無線キーボードも安定してできるのは6キー程度ですので、有線のNKROの物をご使用ください。

##　アスタリスク*なしの略語は実装していません。本家も記号２つ[]を入れていた程度であったため。
アスタリスク*ありの略語は使用できます。最新でない場合や足したい場合など辞書ファイルの.ahkincを適時改変ください。


**キー設定に関して
親指キーに関してはn(n)c(t)v(k)と n(k)m(t),(n)をデフォルトで指定しています。
各自下記キーアサインを改変して使用ください。Addkey後の最初の項目だけ変更ください。
内容は登録するキー入力、左右(LかR)、種類（hyphen, conso, vowel, particle, star）、メジロの場合のキー出力対応(#, *,STKNYAIUntk)の順です。

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


なお、私自身も完全にはサポートできるものでもないこと、使用に関しての障害/弊害等の被害があった場合は自己責任でお願いします。
またメジロ式開発者のじーびす様に突撃するのも迷惑ですのでご遠慮ください。

p.s.
新下駄とBoo配列もいいぞ!みんなもっと新配列を使おう。作ろう!
じーびす様が改良いただいたときにはこちらのページは用済みとなる未来もあるかもしれません（安定版が発表されるのは大変喜ばしいことです）。
