#!/usr/bin/env lsc
global <<< require 'prelude-ls'
{ stdin } = process

running-as-script = not module.parent

stringFromRange = (cs, start, end) ->
  cs.slice(start, end).join('').replace(/[\r\n\s]+/g, ' ')

parseVar = (cs, start, end) ->
  [\var, cs.slice(start, end).join('')]

parseLam = (cs, start, end) ->
  root = [\lam]
  i = start
  while i < end
    switch
    | cs[i] is '\\'
      j = i + 1
      until cs[j] is /[\(\)\\\s]/ => ++j
      root.push cs.slice(i + 1, j).join('')
      func = if cs[j] is '\\' then parseLam else parseApp
      root.push func(cs, j + 1, end)
      i = end
    | otherwise
      ++i
  root

parseApp = (cs, start, end) ->
  ranges = [];
  root = []
  prev = root
  i = start
  while i < end
    switch
    | cs[i] is '('
      j = i + 1
      depth = 1
      loop
        c = cs[j++]
        switch
        | c is '(' => ++depth
        | c is ')' => --depth
        break if depth is 0
      ranges.push [parseApp, i + 1, j - 1]
      i = j
    | cs[i] is '\\'
      ranges.push [parseLam, i, end]
      i = end
    | cs[i] is /[^\(\)\\\s]/
      j = i + 1
      until cs[j] is /[\(\)\\\s]/ => ++j
      ranges.push [parseVar, i, j]
      i = j
    | otherwise
      ++i
  while range = ranges.pop!
    node = [range.0(cs, range.1, range.2)]
    prev = prev.unshift \app, node
    prev = node
  prev.push ...prev.pop! # [[left], right] => [left, right]
  root.1

if running-as-script
  program = ''
  stdin
    .resume!
    .on \data -> program += it
    .on \end  ->
      cs = Array.from program
      console.log JSON.stringify parseApp cs, 0, cs.length
else
  module.exports = ->
    cs = Array.from it
    parseApp cs, 0, cs.length
