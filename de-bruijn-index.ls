annotate = (node, distances = {}) ->
  switch node.0
  | \var
    [\var, node.1, distances[node.1] or 0]
  | \app
    [\app, annotate(node.1, distances), annotate(node.2, distances)]
  | \lam
    d = {}
    for k of distances
      d[k] = distances[k] + 1
    d[node.1] = 1
    [\lam, node.1, annotate(node.2, d)]

increase = (node, value, depth = 0) ->
  switch node.0
  | \var
    index = if node.2 > depth then node.2 + value else node.2
    [\var, node.1, index]
  | \app
    [\app,
      increase(node.1, value, depth),
      increase(node.2, value, depth)]
  | \lam
    [\lam, node.1, increase(node.2, value, depth + 1)]

subs = (body, arg, depth = 1) ->
  switch body.0
  | \var
    switch
    | body.2 > depth
      [\var, body.1, body.2 - 1]
    | body.2 == depth
      increase arg, depth - 1
    | body.2 < depth
      body
  | \app
    [\app,
      subs(body.1, arg, depth),
      subs(body.2, arg, depth)]
  | \lam
    [\lam, body.1, subs(body.2, arg, depth + 1)]

module.exports = {
  annotate,
  increase,
  subs
}
