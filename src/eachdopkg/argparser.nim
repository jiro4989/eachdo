from sequtils import delete

import argparse

const
  helpDoc = """joyn joins lines of two files with a common characters, field or regular expression.

Usage:
  joyn [options...] -- <delimiter> <action> [args...] <delimiter> <action> [args...] <delimiter> <left_source_file> <right_source_file>

Actions:
  c, cut   character mode
  g, grep  regular expression mode

Options of actions:
  grep
    -g, --group <group>         named capturing group.
    -d, --delimiter <delimiter> [default: " "]

  cut
    -c, --characters <characters>
    -f, --field <field>
    -d, --delimiter <delimiter>

Examples:
  joyn -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt

  joyn -o '1.1,1.2,2.2' -- / c -d , -f 3 / c -d " " -f 1 / tests/testdata/user.csv tests/testdata/hobby.txt

  joyn -- / g '\s/([^/]+)/[^s]+\s' / c -d ',' -f 1 / tests/testdata/app.log tests/testdata/user2.csv

  joyn -o '1.1,1.2,1.4,1.5,2.2,1.id' -- \
    / g '\s/([^/]+)/[^s]+\s' -d ' ' -g '\s/(?P<id>[^/]+)/[^s]+\s' \
    / c -d ',' -f 1 \
    / tests/testdata/app.log tests/testdata/user2.csv
"""

type
  Args* = object
    version*, matrix*: bool
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

  var p = newParser("joyn"):
    help(helpDoc)
    flag("-v", "--version")
    flag("-m", "--matrix")

  let opts = p.parse(prefArgs)
  if opts.version:
    result.version = opts.version
    return

  let cp = args[delimPos+1 .. ^1].parseCommandParam()
  result.command = cp[0]
  result.params = cp[1]
