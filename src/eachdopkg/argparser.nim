from sequtils import delete

import argparse

const
  helpDoc = """eachdo executes commands with each multidimensional values.

Usage:
  eachdo [options...] -- <delimiter> <command> [args...] <delimiter> <REPLACE> [args...] [<delimiter> <REPLACE> [args...]]...

Examples:
  $ eachdo / echo % / % 1 2 3
  1
  2
  3

  $ eachdo --matrix -- / echo FIRST LAST / FIRST taro hanako / LAST yamada tanaka 
  taro yamada
  taro tanaka
  hanako yamada
  hanako tanaka
"""

type
  Args* = object
    help*, version*, matrix*: bool
    command*: seq[string]
    params*: seq[Param]
  Param* = object
    varName*: string
    vars*: seq[string]
  InvalidArgsError* = object of CatchableError

proc getPart(args: var seq[string], delim: string): seq[string] =
  for i in 0..args.high:
    let arg = args[0]
    args.delete(0, 0)

    if arg == delim:
      return
    result.add(arg)

proc parseCommandParam*(args: seq[string]): (seq[string], seq[Param]) =
  ## / echo 123%456 / % a b c
  if args.len < 3:
    raise newException(InvalidArgsError, "arguments count must be over 3")
  var args = args
  let delim = args[0]
  args.delete(0, 0)

  result[0] = args.getPart(delim)
  if result[0].len < 1:
    raise newException(InvalidArgsError, "command part is illegal: command = " & $result[0])

  while true:
    let rawParam = args.getPart(delim)
    if rawParam.len < 1:
      raise newException(InvalidArgsError, "param part is illegal: param = " & $rawParam)

    let param = Param(varName: rawParam[0], vars: rawParam[1..^1])
    result[1].add(param)
    if args.len == 0:
      break

proc parseArgs*(args: seq[string]): Args =
  var delimPos: int
  var prefArgs: seq[string]
  for i, arg in args:
    if arg == "--":
      delimPos = i
      break
    prefArgs.add(arg)

  var p = newParser("eachdo"):
    help(helpDoc)
    flag("-v", "--version", help = "Show version")
    flag("-m", "--matrix", help = "Activate brute force combination mode")

  let opts = p.parse(prefArgs)
  if opts.version:
    result.version = opts.version
    return

  result.help = "-h" in prefArgs or "--help" in prefArgs
  if result.help:
    return

  let cp = args[delimPos+1 .. ^1].parseCommandParam()
  result.command = cp[0]
  result.params = cp[1]
  result.matrix = opts.matrix
