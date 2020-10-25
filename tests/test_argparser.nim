import unittest

include eachdopkg/argparser

suite "proc getPart":
  test "normal: command part":
    var args = @["echo", "%", "/", "%", "1", "2"]
    check args.getPart("/") == @["echo", "%"]
    check args == @["%", "1", "2"]
  test "normal: param part":
    var args = @["%", "1", "2"]
    check args.getPart("/") == @["%", "1", "2"]
    check args.len == 0
  test "normal: empty":
    var args: seq[string]
    check args.getPart("/").len == 0

suite "proc parseCommandParam":
  test "normal: success":
    var args = @["/", "echo", "%", "/", "%", "1", "2"]
    check args.parseCommandParam() == (@["echo", "%"], @[Param(varName: "%", vars: @["1", "2"])])
  test "abnormal: no command part":
    var args = @["/", "/", "%", "1", "2"]
    expect InvalidArgsError:
      discard args.parseCommandParam()
  test "abnormal: no param part":
    var args = @["/", "echo", "%", "/"]
    expect InvalidArgsError:
      discard args.parseCommandParam()
  test "abnormal: illegal params":
    var args = @["/", "/"]
    expect InvalidArgsError:
      discard args.parseCommandParam()
