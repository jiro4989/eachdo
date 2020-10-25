import os, osproc, strformat, strutils, streams, sequtils
import eachdopkg/argparser

const
  appName = "eachdo"
  version = &"""{appName} command version 0.1.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/""" & appName

proc matrixDo(cmd: string, tmpl: seq[string], argses: var seq[seq[string]], params: seq[Param]) =
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

  matrixDo(cmd, tmpl, argses, params[1..^1])
  return

proc main(args: seq[string]): int =
  let args = parseArgs(args)
  if args.version:
    echo version
    return

  let cmd = args.command[0]
  if args.matrix:
    var argses: seq[seq[string]]
    matrixDo(cmd, args.command[1..^1], argses, args.params)
    return

  let max = args.params[0].vars.len
  echo max
  let cmds = args.command[1..^1]
  for i in 0..<max:
    var vs: seq[string]
    for j in 0..<cmds.len:
      var tmpl = cmds[j]
      for param in args.params:
        let val =
          if param.vars.len <= i:
            ""
          else:
            param.vars[i]
        tmpl = tmpl.replace(param.varName, val)
      vs.add(tmpl)
    var p = startProcess(cmd, args = vs, options = {poUsePath, poParentStreams})
    discard p.waitForExit()
    close(p)

when isMainModule and not defined modeTest:
  quit main(commandLineParams())
