#!/usr/bin/env lsc
global <<< require 'prelude-ls'
expect = require 'expect'

interpret = require './interpret'
deBruijnIndex = require './de-bruijn-index'
{ stringify, deBruijn } = require './pretty'
tests = require './json/generated_3_6_normal.json'

console.log tests.length
tests.forEach (it, i)->
  result = interpret it.0
  annotated = deBruijnIndex.annotate it.1
  try
    expect deBruijn(result) .toBe deBruijn(annotated)
  catch e
    console.log "#{i * 5 + 3}: #{stringify it.0} should be #{deBruijn annotated} instead of #{deBruijn result}"
