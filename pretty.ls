stringify = (node) ->
  if not node then ''
  switch node.0
  | \var => "#{node.1}"
  | \app => "#{stringify node.1} #{stringify node.2}"
  | \lam => "(\\#{node.1} #{stringify node.2})"

deBruijn = (node) ->
  if not node then ''
  switch node.0
  | \var => " #{node.2}"
  | \app => "#{deBruijn node.1}#{deBruijn node.2}"
  | \lam => "(\\#{deBruijn node.2})"

module.exports = {
  stringify,
  deBruijn
}
