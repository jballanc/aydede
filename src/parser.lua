--[[ parser.lua

  The parser for use with the aydede grammar.

  This is a basic parser that turns events fired during the processing of an input stream
  using the aydede grammar (see: grammar.lua) into a string describing the resulting AST.
  Since scheme is, naturally, very close to an AST already, this parser is mostly useful
  to verify that individual tokens and combinations of tokens are handled correctly by the
  grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local ast = require("ast")

local parser = {}

function parser.list(l)
  print("Parsing list...")
  return ast.list:new(l.car, l.cdr)
end

return parser
