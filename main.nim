import std/[sequtils, strutils]


type
  Unicode = distinct int
  UTF8char = seq[char]
  UTF8string = seq[UTF8char]
  UTF8groupKind = enum
    u4, u3, u2, ascii, partial

const
  utf8Mask: array[UTF8groupKind, int] = [
    0b11110_000,
    0b1110_0000,
    0b110_00000,
    0b0_0000000,
    0b10_000000]


func group(ch: char): UTF8groupKind =
  let i = ord ch

  if i >= utf8Mask[u4]: u4
  elif i >= utf8Mask[u3]: u3
  elif i >= utf8Mask[u2]: u2
  elif i >= utf8Mask[partial]: partial
  else: ascii

func toUtf8(s: string): UTF8string =
  for ch in s:
    if ch.group == partial:
      result[^1].add ch
    else:
      result.add @[ch]

func `$`(uch: UTF8char): string =
  result = newStringOfCAp uch.len
  for i in uch:
    result.add i

func binaryRepr(ch: char): string =
  ch.ord.toBin 8

func binaryRepr(uch: UTF8char): string =
  uch.map(binaryRepr).join " "

func unicode(uch: UTF8char): Unicode =
  var acc = 0

  for ch in uch:
    acc = (acc shl 8) + (ch.ord - utf8Mask[ch.group])

  Unicode acc

func `$`(uc: Unicode): string =
  "U+" & toHex(uc.int, 5)


when isMainModule:
  let data = toUtf8 """
English
فارسی
💩🤣"""
  for uch in data:
    echo uch.binaryRepr, " :: ", $uch, " (", unicode uch, ')'

#[ --- output
01000101 :: E (U+00045)
01101110 :: n (U+0006E)
01100111 :: g (U+00067)
01101100 :: l (U+0006C)
01101001 :: i (U+00069)
01110011 :: s (U+00073)
01101000 :: h (U+00068)
00001010 :: \n (U+0000A)
11011001 10000001 :: ف (U+01901)
11011000 10100111 :: ا (U+01827)
11011000 10110001 :: ر (U+01831)
11011000 10110011 :: س (U+01833)
11011011 10001100 :: ی (U+01B0C)
00001010 :: \n (U+0000A)
11110000 10011111 10010010 10101001 :: 💩 (U+F1229)
11110000 10011111 10100100 10100011 :: 🤣 (U+F2423)
]#
