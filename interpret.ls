#!/usr/bin/env lsc
global <<< require 'prelude-ls'
deBruijnIndex = require './de-bruijn-index'
{ stringify, deBruijn } = require './pretty'

{ stdin } = process

running-as-script = not module.parent

getFreeVars = (node) ->
  switch node.0
  | \var => [node.1]
  | \app => [getFreeVars(node.1), getFreeVars(node.2)] |> flatten |> unique
  | \lam => getFreeVars node.2 |> filter (isnt node.1)

replaceWith = (node, before, after) ->
  switch node.0
  | \var
    if before is node.1
      then [\var, after]
      else node
  | \app
    [\app,
      replaceWith(node.1, before, after),
      replaceWith(node.2, before, after)]
  | \lam
    if before is node.1
      then [\lam, after, replaceWith(node.2, before, after)]
      else [\lam, node.1, replaceWith(node.2, before, after)]

subs = (body, arg, name, frees) ->
  switch body.0
  | \var
    if body.1 is name then arg else body
  | \app
    [\app, subs(body.1, arg, name, frees), subs(body.2, arg, name, frees)]
  | \lam
    if body.1 in frees
      # XXX: should replace until no collision
      body = replaceWith body, body.1, "_#{body.1}"
    if body.1 isnt name
      then [\lam, body.1, subs(body.2, arg, name, frees)]
      else body

weak-env = {}
env = {}

weakNormalForm = (node) ->
  switch node.0
  | \var \lam => node
  | \app
    lam = weakNormalForm node.1
    if lam.0 isnt \lam
      node
    else
      #frees = getFreeVars node.2
      #weakNormalForm subs lam.2, node.2, lam.1, frees
      #weakNormalForm subsDeBruijnIndex lam.2, node.2
      hash = deBruijn node
      unless weak-env[hash]
        weak-env[hash] = weakNormalForm deBruijnIndex.subs lam.2, node.2
      weak-env[hash]

normalForm = (node) ->
  switch node.0
  | \var => node
  | \lam => [\lam, node.1, normalForm(node.2)]
  | \app
    lam = weakNormalForm node.1
    if lam.0 isnt \lam
      [\app, normalForm(node.1), normalForm(node.2)]
    else
      #frees = getFreeVars node.2
      #normalForm subs lam.2, node.2, lam.1, frees
      #normalForm subsDeBruijnIndex lam.2, node.2
      hash = deBruijn node
      unless env[hash]
        env[hash] = normalForm deBruijnIndex.subs lam.2, node.2
      env[hash]

if running-as-script
  program = ''
  stdin
    .resume!
    .on \data -> program += it
    .on \end  ->
      ast = JSON.parse program
      console.log stringify normalForm deBruijnIndex.annotate ast
else
  module.exports = ->
    weak-env := {}
    env := {}
    normalForm deBruijnIndex.annotate it
