#!/usr/bin/env lsc
global <<< require 'prelude-ls'
{ stdin } = process

running-as-script = not module.parent

pretty = (node) ->
  if not node then ''
  switch node.0
  | \var => "#{node.1}"
  | \app => "#{pretty node.1} #{pretty node.2}"
  | \lam => "(\\#{node.1} #{pretty node.2})"

prettyDeBruijnIndex = (node) ->
  if not node then ''
  switch node.0
  | \var => "#{node.2}"
  | \app => "#{prettyDeBruijnIndex node.1}#{prettyDeBruijnIndex node.2}"
  | \lam => "(\\#{prettyDeBruijnIndex node.2})"

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

deBruijnIndex = (node, distances = {}) ->
  switch node.0
  | \var
    [\var, node.1, distances[node.1] or 0]
  | \app
    [\app, deBruijnIndex(node.1, distances), deBruijnIndex(node.2, distances)]
  | \lam
    d = {}
    for k of distances
      d[k] = distances[k] + 1
    d[node.1] = 1
    [\lam, node.1, deBruijnIndex(node.2, d)]

increaseDeBruijnIndex = (node, value, depth = 0) ->
  switch node.0
  | \var
    index = if node.2 > depth then node.2 + value else node.2
    [\var, node.1, index]
  | \app
    [\app,
      increaseDeBruijnIndex(node.1, value, depth),
      increaseDeBruijnIndex(node.2, value, depth)]
  | \lam
    [\lam, node.1, increaseDeBruijnIndex(node.2, value, depth + 1)]

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

subsDeBruijnIndex = (body, arg, depth = 1) ->
  switch body.0
  | \var
    switch
    | body.2 > depth
      [\var, body.1, body.2 - 1]
    | body.2 == depth
      increaseDeBruijnIndex arg, depth - 1
    | body.2 < depth
      body
  | \app
    [\app,
      subsDeBruijnIndex(body.1, arg, depth),
      subsDeBruijnIndex(body.2, arg, depth)]
  | \lam
    [\lam, body.1, subsDeBruijnIndex(body.2, arg, depth + 1)]

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
      weakNormalForm subsDeBruijnIndex lam.2, node.2
      /*
      hash = prettyDeBruijnIndex node
      unless env[hash]
        env[hash] = weakNormalForm subsDeBruijnIndex lam.2, node.2
      env[hash]
      */

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
      normalForm subsDeBruijnIndex lam.2, node.2

if running-as-script
  program = ''
  stdin
    .resume!
    .on \data -> program += it
    .on \end  ->
      ast = JSON.parse program
      console.log pretty normalForm deBruijnIndex ast
      #console.log prettyDeBruijnIndex normalForm deBruijnIndex ast
else
  module.exports = -> normalForm deBruijnIndex it
