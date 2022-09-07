import std/[sequtils, strutils]


type
  Unicode* = distinct int
  UTF8Char* = seq[char]
  UTF8String* = seq[UTF8Char]
  UTF8CharKind* = enum
    u4, u3, u2, ascii, partial

const
  utf8Masks: array[UTF8CharKind, int] = [
    0b11110_000,
    0b1110_0000,
    0b110_00000,
    0b0_0000000,
    0b10_000000]


func group(ch: char): UTF8CharKind =
  ## returns what group of utf-8 `ch` belongs to
  let i = ord ch

  if i >= utf8Masks[u4]: u4
  elif i >= utf8Masks[u3]: u3
  elif i >= utf8Masks[u2]: u2
  elif i >= utf8Masks[partial]: partial
  else: ascii

func toUtf8*(s: string): UTF8String =
  ## converts normal string `s` to utf-8 string
  for ch in s:
    case ch.group:
    of partial: result[^1].add ch
    else: result.add @[ch]

func `$`*(uch: UTF8Char): string =
  ## convets a utf-8 char `uch` to string
  result = newStringOfCAp uch.len
  for i in uch:
    result.add i

func binaryRepr(ch: char): string =
  ## returns binary representation of a char in 8 bits format
  ch.ord.toBin 8

func binaryRepr*(uch: UTF8Char): string =
  ## returns binary representation of a utf-8 char in a sequence of bytes
  uch.map(binaryRepr).join " "

func usableBits(ch: char): int =
  ## returns number os usable bits in character `ch` with respect to utf-8 format
  case group ch:
  of u4: 3
  of u3: 4
  of u2: 5
  of ascii: 7
  of partial: 6

func unicode*(uch: UTF8Char): Unicode =
  # calculates unicode of a utf-8 char `uch`
  var acc = 0

  for ch in uch:
    acc = (acc shl usableBits ch) + (ch.ord - utf8Masks[ch.group])

  Unicode acc

func `$`*(uc: Unicode): string =
  ## converts a unicode number `uc` in `U+hhhhh` format
  "U+" & toHex(uc.int, 5)
