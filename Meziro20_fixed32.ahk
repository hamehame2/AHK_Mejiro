#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook True
; === Mejiro AHK build: FIXED15 (no multi-arg Map initializers) ===
; If you still see 'COMMAND_MAP := Map(' in the error dialog, you are running an older file.
SetKeyDelay -1, -1

#Include *i mejiro_dict_latest_v21.ahkinc

; If the optional include wasn't found, initialize maps so the script still runs.
; (Also prevents #Warn "never assigned" warnings.)
if !IsSet(USERS_MAP)
    global USERS_MAP := Map()
if !IsSet(ABSTRACT_MAP)
    global ABSTRACT_MAP := Map()
if !IsSet(ABSTRACT_MAP_LEFT)
    global ABSTRACT_MAP_LEFT := Map()
if !IsSet(ABSTRACT_MAP_RIGHT)
    global ABSTRACT_MAP_RIGHT := Map()
if !IsSet(VERB_GODAN_MAP)
    global VERB_GODAN_MAP := Map()
if !IsSet(VERB_KAMI_MAP)
    global VERB_KAMI_MAP := Map()
if !IsSet(VERB_SIMO_MAP)
    global VERB_SIMO_MAP := Map()


if !IsSet(CONJUGATE_GODAN_MAP)
    global CONJUGATE_GODAN_MAP := Map()
if !IsSet(CONJUGATE_KAMI_MAP)
    global CONJUGATE_KAMI_MAP := Map()
if !IsSet(CONJUGATE_SIMO_MAP)
    global CONJUGATE_SIMO_MAP := Map()
if !IsSet(AUXILIARY_VERB_LEFT_MAP)
    global AUXILIARY_VERB_LEFT_MAP := Map()
if !IsSet(AUXILIARY_VERB_RIGHT_MAP)
    global AUXILIARY_VERB_RIGHT_MAP := Map()
if !IsSet(AUXILIARY_VERB_EXCEPTION_MAP)
    global AUXILIARY_VERB_EXCEPTION_MAP := Map()
if !IsSet(DESU_CONJUGATE_MAP)
    global DESU_CONJUGATE_MAP := Map()
if !IsSet(SAHEN_LIST)
    global SAHEN_LIST := []
if !IsSet(KAHEN_LIST)
    global KAHEN_LIST := []
if !IsSet(IKU_LIST)
    global IKU_LIST := []
if !IsSet(ARU_LIST)
    global ARU_LIST := []
if !IsSet(GOZARU_LIST)
    global GOZARU_LIST := []
if !IsSet(CONJUGATE_MAP)
    global CONJUGATE_MAP := Map()

if (USERS_MAP.Count = 0 && ABSTRACT_MAP.Count = 0 && ABSTRACT_MAP_LEFT.Count = 0 && ABSTRACT_MAP_RIGHT.Count = 0
    && VERB_GODAN_MAP.Count = 0 && VERB_KAMI_MAP.Count = 0 && VERB_SIMO_MAP.Count = 0) {
    ; If you expect dictionaries but see this, place mejiro_dict.ahkinc next to this script.
    ;ToolTip("mejiro_dict.ahkinc not loaded", 10, 10)
    ;SetTimer(() => ToolTip(), -1200)
}

; タイピングトグル時に押したキーが素通しされる環境向け（必要なら 1→2 など）
TOGGLE_BACKSPACE_COUNT := 2


;----------------------------------
; メジロ ON/OFF
;----------------------------------
global MejiroEnabled := true
global DebugStroke   := false  ; 動作確認用。落ち着いたら false に
global IsTypingMode  := false  ; タイピングモードON/OFF
global TypingMode    := 0      ; 0: ローマ字, 1: JISかな


;========================
; Commands (mejiro_commands.json)
;========================
global LAST_OUTPUT := ""  ; last emitted TEXT (fallback)
global LAST_STROKE := ""  ; last resolved stroke (preferred for "#")
global COMMAND_MAP := Map()
COMMAND_MAP["#"] := "=repeat_last_translation"
COMMAND_MAP["tk#"] := "{PLOVER:TOGGLE}"
COMMAND_MAP["t#"] := "{PLOVER:SWITCH_SYSTEM:English Stenotype}{#alt_l(grave)}"
COMMAND_MAP["k#"] := "{^}{#alt_l(grave)}"
COMMAND_MAP["-U"] := "=undo"
COMMAND_MAP["-AU"] := "{#BackSpace}"
COMMAND_MAP["-IU"] := "{#Delete}"
COMMAND_MAP["-S"] := "{#Escape}"
COMMAND_MAP["-A"] := "{^}{#Left}{^}"
COMMAND_MAP["-N"] := "{^}{#Down}{^}"
COMMAND_MAP["-K"] := "{^}{#Right}{^}"
COMMAND_MAP["-Y"] := "{^}{#Up}{^}"
COMMAND_MAP["-SA"] := "{^}{#shift_l(#Left)}{^}"
COMMAND_MAP["-SN"] := "{^}{#shift_l(#Down)}{^}"
COMMAND_MAP["-SK"] := "{^}{#shift_l(#Right)}{^}"
COMMAND_MAP["-SY"] := "{^}{#shift_l(#Up)}{^}"
COMMAND_MAP["-I"] := "{^}{#Home}{^}"
COMMAND_MAP["-T"] := "{^}{#End}{^}"
COMMAND_MAP["-SI"] := "{^}{#control_l(#Home)}{^}"
COMMAND_MAP["-ST"] := "{^}{#control_l(#End)}{^}"
COMMAND_MAP["-YI"] := "{^（^}"
COMMAND_MAP["-TY"] := "{^）^}"
COMMAND_MAP["-SYI"] := "{^【^}"
COMMAND_MAP["-STY"] := "{^】^}"
COMMAND_MAP["-TYI"] := "{^（）^}{#Left}{^}"
COMMAND_MAP["-STYI"] := "{^【】^}{#Left}{^}"
COMMAND_MAP["-NA"] := "{^「^}"
COMMAND_MAP["-KN"] := "{^」^}"
COMMAND_MAP["-SNA"] := "{^『^}"
COMMAND_MAP["-SKN"] := "{^』^}"
COMMAND_MAP["-KNA"] := "{^「」^}{#Left}{^}"
COMMAND_MAP["-SKNA"] := "{^『』^}{#Left}{^}"
COMMAND_MAP["-NYIA"] := "{^〈^}"
COMMAND_MAP["-TKNY"] := "{^〉^}"
COMMAND_MAP["-SNYIA"] := "{^《^}"
COMMAND_MAP["-STKNY"] := "{^》^}"
COMMAND_MAP["-TKNYIA"] := "{^〈〉^}{#Left}{^}"
COMMAND_MAP["-STKNYIA"] := "{^《》^}{#Left}{^}"
COMMAND_MAP["-TK"] := "{^|^}"
COMMAND_MAP["-TKIA"] := "{^||^}"
COMMAND_MAP["-TN"] := "{^……^}"
COMMAND_MAP["-KY"] := "{^※^}"

EmitText(s, times := 1) {
    global LAST_OUTPUT
    if (times < 1)
        return
    ; Text output path that safely handles special chars like ! ^ + #
    Loop times {
        SendText s
    }

; --- Repeat last stroke (# alone) ----------------------------------------
Mejiro_RepeatLastStroke() {
    global LAST_STROKE, LAST_OUTPUT
    ; Repeat by re-evaluating the last completed stroke. Fallback to last text.
    if (LAST_STROKE = "" || LAST_STROKE = "#") {
        if (IsSet(LAST_OUTPUT) && LAST_OUTPUT != "")
            EmitText(LAST_OUTPUT)
        return
    }
    Mejiro_Lookup(LAST_STROKE)
}
; -------------------------------------------------------------------------

    ; Save for repeat
    LAST_OUTPUT := s
}


ExecuteCommand(cmd) {
    global LAST_OUTPUT

    if RegExMatch(cmd, "^\{PLOVER:") {
        ; AHK単体では未対応（必要なら割当て）
        return
    }

    if (cmd = "=undo") {
        Send "^z"
        return
    }
    if (cmd = "=repeat_last_translation") {
        Mejiro_RepeatLastStroke()
        return
    }

    RunCommandString(cmd)
}

RunCommandString(s) {
    pos := 1
    while RegExMatch(s, "\{([^}]*)\}", &m, pos) {
        token := m[1]
        pos := m.Pos + m.Len

        if (token = "^")
            continue

        if (SubStr(token, 1, 1) = "^" && SubStr(token, -1) = "^") {
            text := SubStr(token, 2, StrLen(token)-2)
            if (text != "")
                Send text
            continue
        }

        if RegExMatch(token, "^#shift_l\(#([A-Za-z]+)\)$", &mm) {
            Send "+{" mm[1] "}"
            continue
        }
        if RegExMatch(token, "^#control_l\(#([A-Za-z]+)\)$", &mm) {
            Send "^{" mm[1] "}"
            continue
        }
        if (token = "#alt_l(grave)") {
            Send "!``"
            continue
        }
        if RegExMatch(token, "^#([A-Za-z]+)$", &mm) {
            Send "{" mm[1] "}"
            continue
        }
    }
}


F12::{  ; F13でON/OFF
    global MejiroEnabled
    MejiroEnabled := !MejiroEnabled
    ToolTip(MejiroEnabled ? "Mejiro ON" : "Mejiro OFF", 10, 10)
    SetTimer(() => ToolTip(), -700)
}

F11::{  ; F14でリロード
    Reload()
}

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

AddKey(key, side, kind, code) {
    global MejiroKeyDef
    MejiroKeyDef[key] := Map("side", side, "kind", kind, "code", code)
}

;----------------------------------
; 内部状態
;----------------------------------
global ActivePhysical := Map()
global LConso := Map(), LVowel := Map(), LPart := Map()
global RConso := Map(), RVowel := Map(), RPart := Map()
global HyphenDup := false
global StarPressed := false
global ChordHasKey := false
global ChordRawSeq := ""
global ChordKeyCount := 0

;----------------------------------
; ホットキー登録
;----------------------------------
InitMejiroHotkeys()

InitMejiroHotkeys() {
    keys := ["q","w","e","r","t"
            ,"a","s","d","f","g"
            ,"z","c","v","b"
            ,"y","u","i","o","p","@"
            ,"h","j","k","l",";",":"
            ,"/","n","m",","]
    for key in keys {
        Hotkey("*" key,       Mejiro_Hk)
        Hotkey("*" key " up", Mejiro_Hk)
    }
}

;----------------------------------
; メインホットキー
;----------------------------------
Mejiro_Hk(*) {
    global MejiroEnabled

    hkName := A_ThisHotkey        ; "*q" / "*q up" など
    isUp   := InStr(hkName, " up")

    key := RegExReplace(hkName, "i)^[*~$#!^+<>]*")  ; 先頭の修飾を除去
    if isUp
        key := RegExReplace(key, "i)\s+up$")        ; " up" を除去

    if !MejiroEnabled {
        ; OFF の時はただのQWERTY
        if isUp
            Send "{" key " up}"
        else
            Send "{" key "}"
        return
    }

    ; Ctrl/Alt/Win が押されている間はメジロ無効（QWERTY素通し）
    if IsAnyModHeld() {
        if isUp
            Send "{Blind}{" key " up}"
        else
            Send "{Blind}{" key " down}"
        return
    }

    if isUp
        Mejiro_KeyUp(key)
    else
        Mejiro_KeyDown(key)
}

;----------------------------------
; Down / Up
;----------------------------------
Mejiro_KeyDown(key) {
    global MejiroKeyDef, ActivePhysical, ChordHasKey, ChordRawSeq
    global LConso, LVowel, LPart, RConso, RVowel, RPart
    global HyphenDup, StarPressed
    global ChordKeyCount

    if !MejiroKeyDef.Has(key) {
        ; メジロ対象外キー → 普通に通す
        Send "{" key "}"
        return
    }

    if !ActivePhysical.Has(key) {
        ActivePhysical[key] := true
        ChordKeyCount += 1
    }

    info := MejiroKeyDef[key]
    side := info["side"], kind := info["kind"], code := info["code"]
    ChordHasKey := true
    ChordRawSeq .= key

    if kind = "conso" {
        (side = "L") ? LConso[code] := true : RConso[code] := true
    } else if kind = "vowel" {
        (side = "L") ? LVowel[code] := true : RVowel[code] := true
    } else if kind = "particle" {
        (side = "L") ? LPart[code] := true : RPart[code] := true
    } else if kind = "hyphen" {
        HyphenDup := true
    } else if kind = "star" {
        StarPressed := true
    }
}

Mejiro_KeyUp(key) {
    global MejiroKeyDef, ActivePhysical, ChordHasKey, ChordRawSeq
    global HyphenDup, StarPressed
    global DebugStroke

    if !MejiroKeyDef.Has(key) {
        ; 対象外キー
        Send "{" key " up}"
        return
    }

    ; ★ ここでは LConso / LVowel などは消さない ★
    if ActivePhysical.Has(key)
        ActivePhysical.Delete(key)
    else {
        ; 押下管理していない KeyUp（素通し等のタイミング差）
        Send "{" key " up}"
        return
    }

    ; 全キー離された瞬間にストローク確定
    if (ActivePhysical.Count = 0 && ChordHasKey) {
        stroke := BuildStroke()

        ; # 単体（#だけ押して離した）: BuildStroke() は必ず "-" を含むため "#-" になる
        ; ここでは Mejiro_Lookup に渡さず、直接「最後のストロークを再評価」する
        if (stroke = "#-") {
            Mejiro_RepeatLastStroke()
            ResetChord()
            return
        }


        ; # は「直前/今回の出力を繰り返す」用
        ; - 単独「#」や typing トグル系（#-n 等）はコマンドとして扱う
        ; - それ以外で # が混ざった場合は、かな変換は通常の stroke で行い、出力だけ2回にする
        dup := false
        if InStr(stroke, "#") {
            if !(stroke = "#-n" || stroke = "n#-" || stroke = "t#-") && !COMMAND_MAP.Has(stroke) {
                dup := true
                stroke := StrReplace(stroke, "#")
            }
        }

        ; ★ commands（完全一致）を優先
        if COMMAND_MAP.Has(stroke) {
            ExecuteCommand(COMMAND_MAP[stroke])


            ResetChord()
            return
        }

        result := Mejiro_Lookup(stroke)  ; かな変換


        if DebugStroke {
            Send "[" stroke ":" result "]"
        } else {
            if (result != "") {
                ; Send は ! ^ + # を修飾キーとして解釈するので、文字列のみは SendText を使う
                if InStr(result, "{")
                    Send result
                else
                        EmitText(result)
                                ; Save last stroke for "#" repeat
                LAST_STROKE := stroke

; # 同時押し時は今回の出力をもう一度（2回分）
                if (dup) {
                    if InStr(result, "{")
                        Send result
                    else
                        EmitText(result)
                }
            }
            else {
                ; 変換失敗時はQWERTYフォールバック。ただし修飾のみ("-"相当)は何も出さない
                pure := StrReplace(stroke, "#")
                pure := StrReplace(pure, "*")
                if (pure != "-")
                    EmitText(ChordRawSeq)
            }
        }

        ResetChord()
    }
}


Mejiro__ToggleCleanup(n) {
    ; トグル時に漏れた文字を後から確実に消す（キー入力→OS反映の後に実行）
    ; n は消す文字数（通常 2: # と n）
    if (n <= 0)
        return
    Send("{BS " . n . "}")
}

ResetChord() {
    global ActivePhysical, ChordHasKey, ChordRawSeq
    global LConso, LVowel, LPart, RConso, RVowel, RPart
    global HyphenDup, StarPressed

    ActivePhysical := Map()
    LConso := Map(), LVowel := Map(), LPart := Map()
    RConso := Map(), RVowel := Map(), RPart := Map()
    HyphenDup := false
    StarPressed := false
    ChordHasKey := false
    ChordRawSeq := ""
}


Mejiro_RepeatLastStroke() {
    global LAST_STROKE, LAST_OUTPUT
    if (LAST_STROKE != "") {
        ; Re-evaluate the last resolved stroke and emit again
        Mejiro_Lookup(LAST_STROKE)
        return
    }
    ; Fallback: if stroke wasn't captured, resend last emitted text (if any)
    if (LAST_OUTPUT != "")
        EmitText(LAST_OUTPUT)
}

BuildStroke() {
    global LConso, LVowel, LPart, RConso, RVowel, RPart, HyphenDup, StarPressed

    leftConso  := BuildOrdered(LConso,  "STKN")
    leftVowel  := BuildOrdered(LVowel,  "YIAU")
    leftPart   := BuildOrdered(LPart,   "ntk")
    rightConso := BuildOrdered(RConso, "STKN")
    rightVowel := BuildOrdered(RVowel, "YIAU")
    rightPart  := BuildOrdered(RPart,  "ntk")

    hyphen := HyphenDup   ? "#" : ""
    star   := StarPressed ? "*" : ""

    return leftConso leftVowel leftPart hyphen "-" rightConso rightVowel rightPart star
}

BuildOrdered(map, orderStr) {
    out := ""
    for ch in StrSplit(orderStr)
        if map.Has(ch)
            out .= ch
    return out
}

;=====================================================
; ここから変換ロジック（前と同じ）
;=====================================================
global LAST_VOWEL_STROKE := "A"

global conso_stroke_to_roma := [
    ["",  "" ],
    ["S", "s"], ["T", "t"], ["K", "k"], ["N", "n"],
    ["ST","r"], ["SK","w"], ["TK","h"],
    ["SN","z"], ["TN","d"], ["KN","g"], ["TKN","b"],
    ["STK","p"],["STN","l"],["SKN","m"],["STKN","f"]
]

global vowel_stroke_to_roma := [
    ["A",  "a"],
    ["I",  "i"],
    ["U",  "u"],
    ["IA", "e"],
    ["AU", "o"],
    ["YA", "ya"],
    ["YU", "yu"],
    ["YAU","yo"]
]

global DIPHTHONG_MAPPING := Map(
    "Y",    ["a",  "い"],
    "YI",   ["yo", "う"],
    "YIA",  ["e",  "い"],
    "YIU",  ["yu", "う"],
    "YIAU", ["u",  "う"],
    "IU",   ["u",  "い"],
    "IAU",  ["o",  "う"]
)

global COMPLEX_DIPHTHONG_MAPPING := Map(
    ; ～ん
    "IAUn",   ["a", "うん"],   ; ~oun, ~own
    "YIn",    ["i", "んぐ"],   ; ~ing
    "YIUn",   ["ya","る"],     ; ~ial
    "YIAUn",  ["a", "る"],     ; ~al
    ; ～っ
    "IAUtk",  ["a", "う"],     ; ~ou, ~ow
    "YItk",   ["i", "ずむ"],   ; ~ism
    "YIUtk",  ["i", "すと"],   ; ~ist
    "Ytk",    ["a", "いざ－"], ; ~izer
    "YIAtk",  ["e", "んす"],   ; ~ense, ~ence
    "YIAUtk", ["u", "る"],     ; ~ul
    ; ～ー
    "IAUntk", ["a", "ぶる"],   ; ~able
    "YIntk",  ["i", "かる"],   ; ~ical
    "YIUntk", ["i", "てぃ－"], ; ~ity
    "YIAUntk",["o", "じ－"]    ; ~ogy
)


global EXCEPTION_KANA_MAP := Map(
    "TNYI", "でぃ",
    "TNYIU", "てぃ",
    "TNYA", "どぅ",
    "TNYAU", "とぅ",
    "TNYU", "でゅ",

    "SKIU", "ゆい",
    "SKYA", "いぇ",
    "SKYU", "ゔゅ",
    "SKYAU", "を",
    "SKYI", "ゐ",
    "SKYIU", "ゑ",
    "SKIAU", "ゎ",
    "SKYIAU", "うぁ",

    "STKNIU", "ゔぃ",
    "STKNIAU", "ゔぇ",
    "STKNYIAU", "ぢぇ",
    "STKNYI", "じぇ",
    "STKNYIU", "しぇ",
    "STKNYA", "ゔぁ",
    "STKNYU", "ちぇ",
    "STKNYAU", "ゔぉ",

    "STN", "",
    "STNIU", "つぃ",
    "STNIAU", "つぉ",
    "STNY", "つぁ",
    "STNYIA", "つぇ",
    "STNYIAU", "てゅ"
)

global ROMA_TO_KANA_MAP := Map(
    "",  ["あ","い","う","え","お","や","ゆ","よ"],
    "k", ["か","き","く","け","こ","きゃ","きゅ","きょ"],
    "s", ["さ","し","す","せ","そ","しゃ","しゅ","しょ"],
    "t", ["た","ち","つ","て","と","ちゃ","ちゅ","ちょ"],
    "n", ["な","に","ぬ","ね","の","にゃ","にゅ","にょ"],
    "h", ["は","ひ","ふ","へ","ほ","ひゃ","ひゅ","ひょ"],
    "m", ["ま","み","む","め","も","みゃ","みゅ","みょ"],
    "r", ["ら","り","る","れ","ろ","りゃ","りゅ","りょ"],
    "w", ["わ","うぃ","ゔ","うぇ","を","やあ","いう","うぉ"],
    "g", ["が","ぎ","ぐ","げ","ご","ぎゃ","ぎゅ","ぎょ"],
    "z", ["ざ","じ","ず","ぜ","ぞ","じゃ","じゅ","じょ"],
    "d", ["だ","ぢ","づ","で","ど","でぃ","てぃ","どぅ"],
    "b", ["ば","び","ぶ","べ","ぼ","びゃ","びゅ","びょ"],
    "p", ["ぱ","ぴ","ぷ","ぺ","ぽ","ぴゃ","ぴゅ","ぴょ"],
    "f", ["ふぁ","ふぃ","ふ","ふぇ","ふぉ","じぇ","しぇ","ちぇ"],
    "l", ["ぁ","ぃ","ぅ","ぇ","ぉ","ゃ","ゅ","ょ"]
)

global PARTICLE_KEY_LIST := ["", "n", "t", "k", "tk", "nt", "nk", "ntk"]
global SECOND_SOUND_LIST := ["", "ん", "つ", "く", "っ", "ち", "き", "ー"]

global DOT  := "。"
global COMMA := "、"

global L_PARTICLE := ["", COMMA, "に", "の", "で", "と", "を", "か"]
global R_PARTICLE := ["", COMMA, "は", "が", "も", "は" COMMA, "が" COMMA, "も" COMMA]

global EXCEPTION_STROKE_MAP := Map(
    "-n",   "{Enter}",
    "n-",   "{Space}",
    "n-n",  "{Tab}",

    "-nt",  DOT,
    "-nk",  COMMA,
    "-ntk", "{F7}",

    "n-nt",  "?",
    "n-nk",  "{!}",
    "n-ntk", "{F8}"
)


; global USERS_MAP loaded from include
global USERS_REQUIRE_ASTERISK := true  ; true にすると * が必要

; --- User dictionary overrides (avoid collisions like IU- vs IU-STU#) ---
; Upstream abbreviations define IU- as 'ういるす'. That collides with 'IU'='いう'.
; We remap virus to a longer stroke and free IU- for 'いう'.
if IsSet(USERS_MAP) {
    if USERS_MAP.Has("IU-") && (USERS_MAP["IU-"] = "ういるす") {
        USERS_MAP.Delete("IU-")
    }
    if !USERS_MAP.Has("IU-STU") {
        USERS_MAP["IU-STU"] := "ういるす"
    }
    ; 互換: 旧ストローク (IU-STU#) を使っている場合
    if !USERS_MAP.Has("IU-STU#") {
        USERS_MAP["IU-STU#"] := "ういるす"
    }
}
; -----------------------------------------------------------------------

; global ABSTRACT_MAP loaded from include
; global ABSTRACT_MAP_LEFT loaded from include
; global ABSTRACT_MAP_RIGHT loaded from include
stroke_to_kana(conso_stroke, vowel_stroke, particle_stroke, asterisk) {
    global LAST_VOWEL_STROKE
    global conso_stroke_to_roma, vowel_stroke_to_roma
    global DIPHTHONG_MAPPING, COMPLEX_DIPHTHONG_MAPPING
    global ROMA_TO_KANA_MAP, PARTICLE_KEY_LIST, SECOND_SOUND_LIST
    global EXCEPTION_KANA_MAP

    ; 母音ストロークの決定と更新
    if (vowel_stroke = "") {
        if (LAST_VOWEL_STROKE = "")
            LAST_VOWEL_STROKE := "A"
        current_vowel := LAST_VOWEL_STROKE
    } else {
        current_vowel := vowel_stroke
        LAST_VOWEL_STROKE := vowel_stroke
    }

    if (conso_stroke . vowel_stroke . particle_stroke = "")
        return ["", "", "", ""]

    ; 子音+母音が空（= 助音だけ）なら追加音だけ
    if (conso_stroke . vowel_stroke = "") {
        partIndex := IndexOf(PARTICLE_KEY_LIST, particle_stroke)
        extra := (partIndex >= 0) ? SECOND_SOUND_LIST[partIndex+1] : ""
        return ["", extra, "", ""]
    }

    ; ★例外かな（本家と同じ）
    if (EXCEPTION_KANA_MAP.Has(conso_stroke . vowel_stroke)) {
        base := EXCEPTION_KANA_MAP[conso_stroke . vowel_stroke]
        partIndex := IndexOf(PARTICLE_KEY_LIST, particle_stroke)
        extra := (partIndex >= 0) ? SECOND_SOUND_LIST[partIndex+1] : ""
        return [base, extra, "", ""]
    }

    ; 子音ストローク -> 子音ローマ字（ここがポイント：空もOK）
    conso_roma := ""
    found := false
    for pair in conso_stroke_to_roma {
        if (pair[1] = conso_stroke) {
            conso_roma := pair[2]  ; "" もあり得る
            found := true
            break
        }
    }
    if !found
        return ["", "", "", ""]

    ; ここから下（母音処理→ROMA_TO_KANA_MAP参照）は今のままでOK
    ; ※ conso_roma が "" でも ROMA_TO_KANA_MAP[""] があるので母音単体が出る

    vowel_roma := ""
    suffix := ""
    extra_sound := ""



    if (asterisk = "" && COMPLEX_DIPHTHONG_MAPPING.Has(current_vowel . particle_stroke)) {
        arr := COMPLEX_DIPHTHONG_MAPPING[current_vowel . particle_stroke]
        vowel_roma := arr[1]
        suffix := arr[2]
        extra_sound := ""
        vowel_index := -1
        for i, pair in vowel_stroke_to_roma {
            if (pair[2] = vowel_roma) {
                vowel_index := i-1
                break
            }
        }
    } else if (DIPHTHONG_MAPPING.Has(current_vowel)) {
        arr := DIPHTHONG_MAPPING[current_vowel]
        vowel_roma := arr[1]
        suffix := arr[2]
        vowel_index := -1
        for i, pair in vowel_stroke_to_roma {
            if (pair[2] = vowel_roma) {
                vowel_index := i-1
                break
            }
        }
        partIndex := IndexOf(PARTICLE_KEY_LIST, particle_stroke)
        extra_sound := (partIndex >= 0) ? SECOND_SOUND_LIST[partIndex+1] : ""
    } else {
        vowel_index := -1
        for i, pair in vowel_stroke_to_roma {
            if (pair[1] = current_vowel) {
                vowel_index := i-1
                vowel_roma := pair[2]
                break
            }
        }
        partIndex := IndexOf(PARTICLE_KEY_LIST, particle_stroke)
        extra_sound := (partIndex >= 0) ? SECOND_SOUND_LIST[partIndex+1] : ""
    }

    if (vowel_roma = "")
        return ["", "", "", ""]

    if !ROMA_TO_KANA_MAP.Has(conso_roma)
        return ["", "", "", ""]

    kana_row := ROMA_TO_KANA_MAP[conso_roma]
    if (vowel_index < 0 || vowel_index >= kana_row.Length)
        return ["", "", "", ""]

    base_kana := kana_row[vowel_index+1]
    return [base_kana . suffix, extra_sound, conso_roma, vowel_roma]
}

IndexOf(arr, val) {
    for i, v in arr
        if (v = val)
            return i-1
    return -1
}

joshi(left_particle_stroke, right_particle_stroke, allow_exception := true) {
    global EXCEPTION_STROKE_MAP, L_PARTICLE, R_PARTICLE, PARTICLE_KEY_LIST, COMMA

    particle_key := left_particle_stroke . "-" . right_particle_stroke
    if (allow_exception && EXCEPTION_STROKE_MAP.Has(particle_key))
        return EXCEPTION_STROKE_MAP[particle_key]

    right_tk := StrReplace(right_particle_stroke, "n")
    l_index := IndexOf(PARTICLE_KEY_LIST, left_particle_stroke)
    r_index := IndexOf(PARTICLE_KEY_LIST, right_tk)

    left_joshi  := (l_index >= 0) ? L_PARTICLE[l_index+1] : ""
    right_joshi := (r_index >= 0) ? R_PARTICLE[r_index+1] : ""

    if (left_particle_stroke = "n") {
        return right_joshi . COMMA
    } else if ( (right_particle_stroke = "k" || right_particle_stroke = "nk")
             && left_particle_stroke != "" && left_particle_stroke != "k") {
        joshi := "の" . left_joshi
        if InStr(right_particle_stroke, "n")
            joshi .= COMMA
        return joshi
    } else {
        joshi := left_joshi . right_joshi
        if InStr(right_particle_stroke, "n")
            joshi .= COMMA
        return joshi
    }
}

abstract_abbreviation_lookup(left_kana_stroke, right_kana_stroke) {
    global ABSTRACT_MAP, ABSTRACT_MAP_LEFT, ABSTRACT_MAP_RIGHT
    key := left_kana_stroke . "-" . right_kana_stroke
    if ABSTRACT_MAP.Has(key)
        return ABSTRACT_MAP[key]
    if ABSTRACT_MAP_LEFT.Has(left_kana_stroke) && ABSTRACT_MAP_RIGHT.Has(right_kana_stroke)
        return ABSTRACT_MAP_LEFT[left_kana_stroke] . ABSTRACT_MAP_RIGHT[right_kana_stroke]
    return ""
}



StrokeToVerb(left_kana_list, right_kana_list, stroke_list) {
    global VERB_GODAN_MAP, VERB_KAMI_MAP, VERB_SIMO_MAP
    global CONJUGATE_GODAN_MAP, CONJUGATE_KAMI_MAP, CONJUGATE_SIMO_MAP, CONJUGATE_MAP
    global AUXILIARY_VERB_LEFT_MAP, AUXILIARY_VERB_RIGHT_MAP, AUXILIARY_VERB_EXCEPTION_MAP
    global DESU_CONJUGATE_MAP, SAHEN_LIST, KAHEN_LIST, IKU_LIST, ARU_LIST, GOZARU_LIST
    global DOT, COMMA

    left_kana  := left_kana_list[1]
    left_extra := left_kana_list[2]
    left_conso := left_kana_list[3]

    right_kana  := right_kana_list[1]
    right_extra := right_kana_list[2]
    right_conso := right_kana_list[3]

    left_conso_stroke  := stroke_list[1]
    left_vowel_stroke  := stroke_list[2]
    left_particle      := stroke_list[3]
    hyphen             := stroke_list[4]
    right_conso_stroke := stroke_list[5]
    right_vowel_stroke := stroke_list[6]
    right_particle     := stroke_list[7]

    main_kana   := left_kana . right_kana
    kana_stroke := left_conso_stroke . left_vowel_stroke . "-" . right_conso_stroke . right_vowel_stroke

    ; --- 活用を取得 (Python: stroke_to_conjugate) ---
    auxForm := 4   ; default: 辞書形
    auxSuffix := ""
    key := left_particle . "-" . right_particle

    if (AUXILIARY_VERB_EXCEPTION_MAP.Has(key)) {
        tmp := AUXILIARY_VERB_EXCEPTION_MAP[key]
        auxForm := tmp[1]
        auxSuffix := tmp[2]
    } else if (left_particle != "") {
        l := AUXILIARY_VERB_LEFT_MAP[left_particle]   ; [form, stem, conjGroup, row]
        r := AUXILIARY_VERB_RIGHT_MAP[right_particle] ; [form, suffix]
        auxForm := l[1]
        auxSuffix := l[2]
        conjGroup := l[3], conjRow := l[4]
        rForm := r[1]
        auxSuffix .= CONJUGATE_MAP[conjGroup][conjRow][rForm + 1]
        auxSuffix .= r[2]
    } else {
        r := AUXILIARY_VERB_RIGHT_MAP[right_particle]
        auxForm := r[1]
        auxSuffix := r[2]
    }

    ; te/ta形の濁音化：行が g/n/b/m のとき、助動詞「て/た」を「で/だ」に
    if (auxForm = 5 && (right_conso = "g" || right_conso = "n" || right_conso = "b" || right_conso = "m")) {
        auxSuffix := StrReplace(StrReplace(auxSuffix, "て", "で"), "た", "だ")
    }

    ; --- 登録動詞 ---
    if (VERB_GODAN_MAP.Has(kana_stroke)) {
        v := VERB_GODAN_MAP[kana_stroke]  ; [stem,row]
        stem := v[1], row := v[2]
        out := stem . CONJUGATE_GODAN_MAP[row][auxForm + 1] . auxSuffix
        out := StrReplace(out, "あらな", "な")
        return out
    }
    if (VERB_KAMI_MAP.Has(kana_stroke)) {
        v := VERB_KAMI_MAP[kana_stroke]  ; [stem,row]
        stem := v[1], row := v[2]
        out := stem . CONJUGATE_KAMI_MAP[row][auxForm + 1] . auxSuffix
        return out
    }
    if (VERB_SIMO_MAP.Has(kana_stroke)) {
        v := VERB_SIMO_MAP[kana_stroke]  ; [stem,row]
        stem := v[1], row := v[2]
        out := stem . CONJUGATE_SIMO_MAP[row][auxForm + 1] . auxSuffix
        return out
    }

    ; --- 特殊 ---
    if (kana_stroke = "I-K") {
        return IKU_LIST[auxForm + 1] . auxSuffix
    }
    if (kana_stroke = "A-") {
        return ARU_LIST[auxForm + 1] . auxSuffix
    }
    if (kana_stroke = "KNAU-SNA") {
        out := GOZARU_LIST[auxForm + 1] . auxSuffix
        out := StrReplace(out, "ござり", "ござい")
        return out
    }
    if (kana_stroke = "K-") {
        return KAHEN_LIST[auxForm + 1] . auxSuffix
    }

    ; サ変（右が空）
    if (right_kana = "") {
        out := main_kana . SAHEN_LIST[auxForm + 1] . auxSuffix
        out := StrReplace(out, "しず", "せず")
        return out
    }

    ; ～です（Python: right_conso_stroke=='TN' and right_vowel_stroke==''）
    if (right_conso_stroke = "TN" && right_vowel_stroke = "") {
        key2 := right_particle
        if !DESU_CONJUGATE_MAP.Has(key2)
            key2 := ""
        return known := left_kana . left_extra . DESU_CONJUGATE_MAP[key2]
    }

    ; 五段（右が子音だけ）
    if (right_vowel_stroke = "" && (right_conso = "k" || right_conso = "g" || right_conso = "s" || right_conso = "t" || right_conso = "n" || right_conso = "b" || right_conso = "m" || right_conso = "r" || right_conso = "w")) {
        out := left_kana . CONJUGATE_GODAN_MAP[right_conso][auxForm + 1] . auxSuffix
        return out
    }

    ; 上一段
    if (right_vowel_stroke = "I" && (right_conso = "k" || right_conso = "g" || right_conso = "z" || right_conso = "t" || right_conso = "n" || right_conso = "b" || right_conso = "m" || right_conso = "r" || right_conso = "w" || right_conso = "")) {
        row := right_conso
        if (row = "")
            row := "w"
        out := left_kana . CONJUGATE_KAMI_MAP[row][auxForm + 1] . auxSuffix
        return out
    }

    ; 下一段
    if (right_vowel_stroke = "IA" && (right_conso = "k" || right_conso = "g" || right_conso = "s" || right_conso = "z" || right_conso = "t" || right_conso = "d" || right_conso = "n" || right_conso = "h" || right_conso = "b" || right_conso = "m" || right_conso = "r" || right_conso = "w" || right_conso = "")) {
        row := right_conso
        if (row = "")
            row := "w"
        out := left_kana . CONJUGATE_SIMO_MAP[row][auxForm + 1] . auxSuffix
        return out
    }

    ; 「～る」動詞(五段活用)
    out := main_kana . CONJUGATE_GODAN_MAP["r"][auxForm + 1] . auxSuffix
    out := StrReplace(out, "ござり", "ござい")
    return out
}


Mejiro_Lookup(stroke) {
    global USERS_MAP
    global IsTypingMode, TypingMode

    ; typing mode toggle (Python版: "#n"=on, "n#"=off)
    ; AHKのstroke表現は必ず "-" を含むので、
    ;   "#-n" = "#n" 相当 (ON)
    ;   "n#-" = "n#" 相当 (OFF)
    if (stroke = "#-n") {
        IsTypingMode := true
        if (TOGGLE_BACKSPACE_COUNT > 0)
            SetTimer(Mejiro__ToggleCleanup.Bind(TOGGLE_BACKSPACE_COUNT), -30)
        return Mejiro_FinalizeResult("")
    } else if (stroke = "n#-") {
        IsTypingMode := false
        if (TOGGLE_BACKSPACE_COUNT > 0)
            SetTimer(Mejiro__ToggleCleanup.Bind(TOGGLE_BACKSPACE_COUNT), -30)
        return Mejiro_FinalizeResult("")
    } else if (stroke = "t#-") {
        TypingMode := (TypingMode = 0) ? 1 : 0
        return Mejiro_FinalizeResult("")
    }

    if (stroke = "")
        return Mejiro_FinalizeResult("")

    if !RegExMatch(stroke
        , "^(S?T?K?N?)(Y?I?A?U?)(n?t?k?)(#?)-(S?T?K?N?)(Y?I?A?U?)(n?t?k?)(\*?)$", &m)
        return Mejiro_FinalizeResult("")

    left_conso  := m[1], left_vowel  := m[2], left_part  := m[3]
    hyphen_dup := m[4]
    hyphen      := m[4]
    right_conso := m[5], right_vowel := m[6], right_part := m[7]
    asterisk    := m[8]

    left_kana_stroke  := left_conso  . left_vowel
    right_kana_stroke := right_conso . right_vowel
    left_stroke  := left_conso  . left_vowel  . left_part
    right_stroke := right_conso . right_vowel . right_part
    main_stroke  := left_stroke . "-" . right_stroke
    full_stroke := left_stroke . hyphen_dup . "-" . right_stroke . asterisk

    left_list  := stroke_to_kana(left_conso,  left_vowel,  left_part,  asterisk)
    right_list := stroke_to_kana(right_conso, right_vowel, right_part, asterisk)

    left_kana := left_list[1], left_extra := left_list[2]
    right_kana := right_list[1], right_extra := right_list[2]

    main_kana  := left_kana . right_kana
    main_base  := left_kana . left_extra . right_kana . right_extra
    main_joshi := joshi(left_part, right_part, (main_kana = ""))
    abstract   := abstract_abbreviation_lookup(left_kana_stroke, right_kana_stroke)

    if (USERS_MAP.Has(main_stroke) && (!USERS_REQUIRE_ASTERISK || asterisk)) {
        return Mejiro_FinalizeResult(USERS_MAP[main_stroke])
    } else if (main_kana = "" && main_joshi != "" && !asterisk) {
        return Mejiro_FinalizeResult(main_joshi)
    } else if (asterisk) {
        global VERB_KAMI_MAP

        ; 特殊略語：～ing
        if (left_kana != "" && right_kana != "" && StrLen(main_base) > 2
            && !VERB_KAMI_MAP.Has(left_kana_stroke . "-" . right_kana_stroke)) {
            lastKana := SubStr(main_kana, -1)
            if (InStr("いきしちにひみりぎじぢびぴぃ", lastKana) && SubStr(main_base, -1) = "ん")
                return Mejiro_FinalizeResult(main_base . "ぐ")
        }

        ; 一般略語
        if (abstract != "") {
            joshi2 := StrReplace(StrReplace(main_joshi, "～", "です" . DOT), "・", "です")
            return Mejiro_FinalizeResult(abstract . joshi2)
        }

        ; 動詞略語
        stroke_list := [left_conso, left_vowel, left_part, hyphen, right_conso, right_vowel, right_part, asterisk]
        verb := StrokeToVerb(left_list, right_list, stroke_list)
        if (verb != "")
            return Mejiro_FinalizeResult(verb)

        ; 通常
        return Mejiro_FinalizeResult((hyphen = "#") ? main_base . main_base : main_base)
    } else if (left_kana != "" && right_kana = "" && right_part != "") {

        return Mejiro_FinalizeResult(left_kana . main_joshi)
    } else {
        return Mejiro_FinalizeResult((hyphen = "#") ? main_base . main_base : main_base)
    }
}


;----------------------------------
; Typing mode helpers
;----------------------------------
global HEPBURN_ROMA_MAP := Map(
    "きゃ", "kya",
    "きゅ", "kyu",
    "きょ", "kyo",
    "きぇ", "kye",
    "ぎゃ", "gya",
    "ぎゅ", "gyu",
    "ぎょ", "gyo",
    "ぎぇ", "gye",
    "くぁ", "qa",
    "くぃ", "qi",
    "くぇ", "qe",
    "くぉ", "qo",
    "しゃ", "sha",
    "しゅ", "shu",
    "しょ", "sho",
    "しぇ", "she",
    "じゃ", "ja",
    "じゅ", "ju",
    "じょ", "jo",
    "じぇ", "je",
    "ちゃ", "cha",
    "ちゅ", "chu",
    "ちょ", "cho",
    "ちぇ", "che",
    "ぢゃ", "dya",
    "ぢゅ", "dyu",
    "ぢょ", "dyo",
    "ぢぇ", "dye",
    "つぁ", "tsa",
    "つぃ", "tsi",
    "つぇ", "tse",
    "つぉ", "tso",
    "てゃ", "tha",
    "てゅ", "thu",
    "てょ", "tho",
    "てぇ", "the",
    "でゃ", "dha",
    "でゅ", "dhu",
    "でょ", "dho",
    "でぇ", "dhe",
    "てぃ", "thi",
    "とぅ", "twu",
    "でぃ", "dhi",
    "どぅ", "dwu",
    "にゃ", "nya",
    "にゅ", "nyu",
    "にょ", "nyo",
    "にぇ", "nye",
    "ひゃ", "hya",
    "ひゅ", "hyu",
    "ひょ", "hyo",
    "ひぇ", "hye",
    "びゃ", "bya",
    "びゅ", "byu",
    "びょ", "byo",
    "びぇ", "bye",
    "ぴゃ", "pya",
    "ぴゅ", "pyu",
    "ぴょ", "pyo",
    "ぴぇ", "pye",
    "ふぁ", "fa",
    "ふぃ", "fi",
    "ふぇ", "fe",
    "ふぉ", "fo",
    "みゃ", "mya",
    "みゅ", "myu",
    "みょ", "myo",
    "みぇ", "mye",
    "りゃ", "rya",
    "りゅ", "ryu",
    "りょ", "ryo",
    "りぇ", "rye",
    "うぁ", "wha",
    "うぃ", "wi",
    "うぇ", "we",
    "うぉ", "who",
    "ゔぁ", "va",
    "ゔぃ", "vi",
    "ゔぇ", "ve",
    "ゔぉ", "vo",
    "あ", "a",
    "い", "i",
    "う", "u",
    "え", "e",
    "お", "o",
    "ぁ", "la",
    "ぃ", "li",
    "ぅ", "lu",
    "ぇ", "le",
    "ぉ", "lo",
    "か", "ka",
    "き", "ki",
    "く", "ku",
    "け", "ke",
    "こ", "ko",
    "が", "ga",
    "ぎ", "gi",
    "ぐ", "gu",
    "げ", "ge",
    "ご", "go",
    "さ", "sa",
    "し", "shi",
    "す", "su",
    "せ", "se",
    "そ", "so",
    "ざ", "za",
    "じ", "ji",
    "ず", "zu",
    "ぜ", "ze",
    "ぞ", "zo",
    "た", "ta",
    "ち", "chi",
    "つ", "tsu",
    "て", "te",
    "と", "to",
    "だ", "da",
    "ぢ", "di",
    "づ", "du",
    "で", "de",
    "ど", "do",
    "な", "na",
    "に", "ni",
    "ぬ", "nu",
    "ね", "ne",
    "の", "no",
    "は", "ha",
    "ひ", "hi",
    "ふ", "fu",
    "へ", "he",
    "ほ", "ho",
    "ば", "ba",
    "び", "bi",
    "ぶ", "bu",
    "べ", "be",
    "ぼ", "bo",
    "ぱ", "pa",
    "ぴ", "pi",
    "ぷ", "pu",
    "ぺ", "pe",
    "ぽ", "po",
    "ま", "ma",
    "み", "mi",
    "む", "mu",
    "め", "me",
    "も", "mo",
    "や", "ya",
    "ゆ", "yu",
    "よ", "yo",
    "ゃ", "lya",
    "ゅ", "lyu",
    "ょ", "lyo",
    "ら", "ra",
    "り", "ri",
    "る", "ru",
    "れ", "re",
    "ろ", "ro",
    "わ", "wa",
    "を", "wo",
    "ん", "N",
    "っ", "Q",
    "ゔ", "vu",
    "-", "-",
    ",", ",",
    ".", ".",
    "ー", "-",
    "、", ",",
    "。", "."
)

global JIS_KANA_MAP := Map(
    "あ", "3",
    "い", "e",
    "う", "4",
    "え", "5",
    "お", "6",
    "ぁ", "#",
    "ぃ", "E",
    "ぅ", "$",
    "ぇ", "%",
    "ぉ", "&",
    "か", "t",
    "き", "g",
    "く", "h",
    "け", ":",
    "こ", "b",
    "が", "t@",
    "ぎ", "g@",
    "ぐ", "h@",
    "げ", ":@",
    "ご", "b@",
    "さ", "x",
    "し", "d",
    "す", "r",
    "せ", "p",
    "そ", "c",
    "ざ", "x@",
    "じ", "d@",
    "ず", "r@",
    "ぜ", "p@",
    "ぞ", "c@",
    "た", "q",
    "ち", "a",
    "つ", "z",
    "て", "w",
    "と", "s",
    "だ", "q@",
    "ぢ", "a@",
    "づ", "z@",
    "で", "w@",
    "ど", "s@",
    "な", "u",
    "に", "i",
    "ぬ", "1",
    "ね", ",",
    "の", "k",
    "は", "f",
    "ひ", "v",
    "ふ", "2",
    "へ", "^",
    "ほ", "-",
    "ば", "f@",
    "び", "v@",
    "ぶ", "2@",
    "べ", "^@",
    "ぼ", "-@",
    "ぱ", "f[",
    "ぴ", "v[",
    "ぷ", "2[",
    "ぺ", "^[",
    "ぽ", "-[",
    "ま", "j",
    "み", "n",
    "む", "]",
    "め", "/",
    "も", "m",
    "や", "7",
    "ゆ", "8",
    "よ", "9",
    "ゃ", "'",
    "ゅ", "(",
    "ょ", ")",
    "ら", "o",
    "り", "l",
    "る", ".",
    "れ", ";",
    "ろ", "\",
    "わ", "0",
    "を", "}{#Shift(0)}{",
    "ん", "y",
    "っ", "Z",
    "ゔ", "4@",
    "-", "|",
    ",", "<",
    ".", ">",
    "ー", "|",
    "、", "<",
    "。", ">"
)

Mejiro_FinalizeResult(result) {
    global IsTypingMode, TypingMode
    if (!IsTypingMode)
        return result
    if (result = "")
        return result
    ; コマンド("{...}") はタイピング変換しない（そのまま送る）
    if InStr(result, "{")
        return result
    return KanaToTypingOutput(result, TypingMode)
}

KanaToTypingOutput(kana, typing_mode := 0) {
    ; typing_mode: 0=ローマ字, 1=JISかな
    static PendingSokuon := false

    ; 前回持ち越した促音「っ」を先頭に付与
    working := (PendingSokuon ? "っ" : "") . kana
    PendingSokuon := false

    ; 今回の文字列が促音で終わる場合は出力せず持ち越す
    if (SubStr(working, -0) = "っ") { ; ←実際は末尾判定
    }

    ; AHK v2のSubStrは末尾取得が SubStr(str, -1)
    if (SubStr(working, -1) = "っ") {
        PendingSokuon := true
        working := SubStr(working, 1, StrLen(working) - 1)
        if (working = "")
            return ""
    }

    if (typing_mode = 0) {
        raw := HiraganaToRomaji(working)

        ; 小文字「っ」(Q) -> 次の子音を重ねる (例: niQpoN -> nippoN)
        out := RegExReplace(raw, "Q([bcdfghjklmnpqrstvwxyz])", "$1$1")

        ; 撥音「ん」(N) -> 後続が子音/Q のとき n にする
        out := RegExReplace(out, "N([bcdfghjklmpqrstvwxzQ])", "n$1")

        ; 残った N は nn
        out := StrReplace(out, "N", "nn")

        ; 残った Q は ltsu
        out := StrReplace(out, "Q", "ltsu")
        return out
    } else {
        return HiraganaToJisKana(working)
    }
}

HiraganaToRomaji(text) {
    global HEPBURN_ROMA_MAP
    result := ""
    i := 1
    len := StrLen(text)
    while (i <= len) {
        ; 2文字優先
        if (i < len) {
            two := SubStr(text, i, 2)
            if HEPBURN_ROMA_MAP.Has(two) {
                result .= HEPBURN_ROMA_MAP[two]
                i += 2
                continue
            }
        }
        one := SubStr(text, i, 1)
        if HEPBURN_ROMA_MAP.Has(one)
            result .= HEPBURN_ROMA_MAP[one]
        else
            result .= one
        i += 1
    }
    return result
}

HiraganaToJisKana(text) {
    global JIS_KANA_MAP
    result := ""
    i := 1
    len := StrLen(text)
    while (i <= len) {
        ch := SubStr(text, i, 1)
        if JIS_KANA_MAP.Has(ch)
            result .= JIS_KANA_MAP[ch]
        else
            result .= ch
        i += 1
    }
    return result
}

IsAnyModHeld() {
    ; Win / Alt / Ctrl が押されていたら true
    return GetKeyState("Ctrl", "P")
        || GetKeyState("LCtrl", "P")
        || GetKeyState("RCtrl", "P")
        || GetKeyState("Alt", "P")
        || GetKeyState("LAlt", "P")
        || GetKeyState("RAlt", "P")
        || GetKeyState("LWin", "P")
        || GetKeyState("RWin", "P")
}