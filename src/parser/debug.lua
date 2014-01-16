--[[ parser/debug.lua

  A debug parser for use with the aydede grammar.

  This is a basic parser that turns events fired during the processing of an input stream
  using the aydede grammar (see: grammar.lua) into a string describing the resulting AST.
  Since scheme is, naturally, very close to an AST already, this parser is mostly useful
  to verify that individual tokens and combinations of tokens are handled correctly by the
  grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local parser = {}

-- The goal here is that parsing a form like:
--
--     (foo (bar "string") (baz 2.0))
--
-- should produce the following output:
--
--     [:list
--       [:symbol foo],
--       [:list
--         [:symbol bar],
--         [:string string]],
--       [:list
--         [:symbol baz],
--         [:float 2.0]]]
--
function parser.onlist(l)
  print("[:list")
  print("\t[:car "..l.car.."],")
  if type(l.cdr) == "table" then
    print("\t[:cdr ")
    for k,v in pairs(l.cdr) do
      print("\t\t[:"..k.." "..v.."],")
    end
    print("\t]]")
  else
    print("\t[:cdr "..l.cdr.."]]")
  end

  return l
end

return parser
