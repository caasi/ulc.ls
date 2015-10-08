#!/usr/bin/env lsc
global <<< require 'prelude-ls'
{ stdin } = process

# main
program = ''
stdin
  .resume!
  .on \data -> program += it
  .on \end  ->
    console.log parse createStack program

createStack = (program) ->
  i = 0
  tokens = []
  pop = ->
    | tokens.length => tokens.pop!
    | otherwise     => program[i++]
  push = ->
    tokens.push it
  popLevel = ->
    result = []
    level = 0
    while c = pop!
      switch
      | c is '('
        ++level
      | c is ')'
        if level
          --level
        else
          push c
          return result
      | otherwise
        result.push c
    result
  pushAll = (cs) ->
    while c = cs.pop! => push c

  { push, pop, popLevel, pushAll }

# patch
patch = ({ push, pop, popLevel, pushAll }:stack) ->
  while c = pop!
    switch
    | c is /\s/
      continue
    | c is '('
      return parse stack
    | c is '\\' or c is /[^\(\)]/
      program = popLevel!
      push ')'
      pushAll program
      push c
      return parse stack

# parse
# String -> Int -> SyntaxTree
parse = ({ push, pop }:stack) ->
  current = ['app']
  # remove heading spaces
  while c = pop!
    if c isnt /\s/
      push c
      break
  while c = pop!
    switch
    | c is ')'
      return current
    | c is '\\'
      current.push parseLambda stack
    | c is '('
      current.push parse stack
    | c is /[^\s]/
      push c
      current.push parseVar stack
  console.log current
  current

# parseVar and parseLambda assume there are no heading spaces.
parseVar = ({ push, pop }) ->
  name = ''
  while c = pop!
    switch
    | c is /[\)\s]/  => return ['var', name]
    | c is /[^\(]/ => name += c
    | otherwise    => throw new Error "invalid var name: '#c'"

parseLambda = ({ push, pop }:stack) ->
  ready = false
  name = ''
  body = null
  while c = pop!
    switch
    | c is '('
      body = parse stack
    | c is ')'
      return ['lam', name, body]
    | c is /\s/
      ready = true
    | otherwise
      if ready
        push c
        body = patch stack
      else
        name += c

# mergeFrees
mergeFrees = ([xs = {}, ys = {}]) ->
  rs = {}
  xs |> obj-to-pairs |> each ([xk, xv]) ->
    ys |> obj-to-pairs |> each ([yk, yv]) ->
      if not rs[xk] then rs[xk] = []
      rs[xk].push xv
      if not rs[yk] then rs[yk] = []
      rs[yk].push yv
  rs

# calculateFrees
calculateFrees = (tree) ->
  | not tree                 => {}
  | not tree.children.length => tree.free
  | otherwise
    tree.children |> map calculateFrees |> mergeFrees

# show
show = (tree) ->
  if not tree then return ''
  switch tree.type
  | \lam => "(\\#{tree.bounded.name} #{show tree.children.0})"
  | \var => "#{keys(tree.free).0}"
  | \app => "#{show tree.children.0} #{show tree.children.1}"

# weakHeadNormalForm
weakHeadNormalForm = (tree) ->
  ...

sub = (func, arg, name) ->
  ...
