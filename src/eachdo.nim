import os, osproc, strformat, strutils, streams, sequtils
import eachdopkg/argparser

const
  appName = "eachdo"
  version = &"""{appName} command version 0.1.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/""" & appName

proc bruteForce(cmd: string, tmpl: seq[string], argses: var seq[seq[string]], params: seq[Param]) =
  if params.len < 1:
    for args in argses:
      var p = startProcess(cmd, args = args, options = {poUsePath, poParentStreams})
      discard p.waitForExit()
      close(p)
    return

  if argses.len < 1:
    let p = params[0]
    for val in p.vars:
      argses.add(tmpl.mapIt(it.replace(p.varName, val)))
  else:
    var tmp: seq[seq[string]]
    for i in 0..<argses.len:
      let p = params[0]
      var args = argses[i]
      for val in p.vars:
        tmp.add(args.mapIt(it.replace(p.varName, val)))
    argses = tmp

  bruteForce(cmd, tmpl, argses, params[1..^1])
  return

proc main(args: seq[string]): int =
  let args = parseArgs(args)
  if args.version:
    echo version
    return

  let cmd = args.command[0]
  var argses: seq[seq[string]]
  bruteForce(cmd, args.command[1..^1], argses, args.params)

when isMainModule and not defined modeTest:
  quit main(commandLineParams())
