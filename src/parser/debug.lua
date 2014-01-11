local parser = {}

function parser.onlist(l)
  print("List contents:")
  for k,v in pairs(l) do print(k,v) end
end

return parser
