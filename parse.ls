#!/usr/bin/env lsc
global <<< require 'prelude-ls'
{ stdin } = process

running-as-script = not module.parent

isLam = (cs, start, end) ->
  confirm = false
  for i from start til end
    if cs[i] is /\s/
      continue
    else if cs[i] is '\\'
      confirm = true
      break
    else
      break
  #console.log cs.slice(start, end).join('').replace(/[\r\n\s]+/g, ' ')
  #console.log confirm
  confirm

parseVar = (cs, start, end) ->
  if (start > end) then [start, end] = [end + 1, start + 1]
  [\var, cs.slice(start, end).join('')]

parseLam = (cs, start, end) ->
  root = [\lam]
  i = start
  while i isnt end
    c = cs[i]
    switch
    | c is '\\'
      j = i + 1
      until cs[j] is /\s/ => ++j
      root.push cs.slice(i + 1, j).join('')
      root.push if isLam(cs, j + 1, end)
        then parseLam(cs, j + 1, end)
        else parseApp(cs, end - 1, j)
      i = end
    | otherwise
      ++i
  root

parseApp = (cs, start, end) ->
  root = []
  prev = root
  name-idx = void
  depth = 1
  i = end + 1
  while i isnt start + 1
    switch
    | cs[i] is '(' => ++depth
    | cs[i] is ')' => --depth
    break if depth is 1 and cs[i] is '\\'
    ++i
  if i isnt start + 1 # found a lambda
    curr = [parseLam(cs, i, start + 1)]
    prev = prev.unshift \app, curr
    prev = curr
  --i
  while i isnt end
    c = cs[i]
    switch
    | c is ')'
      depth = 1
      j = i - 1
      loop
        switch
        | cs[j] is ')' => ++depth
        | cs[j] is '(' => --depth
        break if depth is 0
        --j
      curr = if isLam(cs, j + 1, i)
        then [parseLam(cs, j + 1, i)]
        else [parseApp(cs, i - 1, j)]
      prev.unshift \app, curr
      prev = curr
      i = j - 1
    | c is /\s/
      if name-idx isnt void
        curr = [parseVar(cs, name-idx, i)]
        prev.unshift \app, curr
        prev = curr
        name-idx = void
      --i
    | otherwise
      if name-idx is void
        name-idx = i
      --i
  if name-idx isnt void
    curr = [parseVar(cs, name-idx, i)]
    prev.unshift \app, curr
    prev = curr
    name-idx = void
  prev.push ...prev.pop!
  root.1

if running-as-script
  program = ''
  stdin
    .resume!
    .on \data -> program += it
    .on \end  ->
      cs = Array.from program
      console.log JSON.stringify parseApp cs, cs.length - 1, -1
else
  module.exports = ->
    cs = Array.from it
    parseApp cs, cs.length - 1, -1
