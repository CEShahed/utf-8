import std/[unittest]
import utf8 {.all.}

suite "UTF-8 functionalities":
  let
    lol = "😂"
    persian = "سلام"
    math = "∆x"

  test "group":
    check group(lol[0]) == u4
    check group(math[0]) == u3
    check group(persian[0]) == u2
    check group('e') == ascii

    check group(lol[1]) == partial
    check group(lol[2]) == partial
    check group(lol[3]) == partial

  test "toUtf8":
    check toUtf8("∆س") == @[
      @[0b11100010.char, 0b10001000.char, 0b10000110.char],
      @[0b11011000.char, 0b10110011.char]]

  test "utf8-char -> string":
    let s = toUtf8 persian
    check $s[0] == "س"

  test "binaryRepr":
    check binaryRepr('E') == "01000101"

    let s = toUtf8 persian
    check binaryRepr(s[0]) == "11011000 10110011"

  test "unicode":
    let code = unicode toUtf8(math)[0]
    check code.int == 0x02206
    check $code == "U+02206"
