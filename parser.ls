#!/usr/bin/env lsc
global <<< require 'prelude-ls'
{ stdin } = process

# main
program = ''
stdin
  .resume!
  .on \data -> program += it
  .on \end  ->
    show stringify parse two createStack program

createStack = (program) ->
  i = 0
  tokens = []
  pop = ->
    | tokens.length => tokens.pop!
    | otherwise     => program[i++]
  push = ->
    tokens.push it
  { push, pop }

one = ({ push, pop }:stack) ->
  name = ''
  do
    c = pop!
  while c is /\s/
  return unless c
  do
    switch
    | c is /[\s\)]/  => return name
    | c is /[^\(]/ => name += c
  while c = pop!
  name

two = ({ push, pop }:stack) ->
  current = []
  do
    c = pop!
  while c is /\s/
  return current unless c
  do
    switch
    | c is /[\(\\]/
      current.push two stack
    | c is /[^\)]/
      push c
      v = one stack
      current.push v if v
    | otherwise
      return current
    return current if current.length is 2
  while c = pop!
  current

parse = ->
  | it.0 |> is-type \String
    if it.length is 2
      then [\lam, it.0, parse(it.1)]
      else [\var it.0]
  | otherwise
    if it.length is 2
      then [\app, parse(it.0), parse(it.1)]
      else parse it.0

show = ->
  console.log it
  it

stringify = -> JSON.stringify it
