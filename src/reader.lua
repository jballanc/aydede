--[[ reader.lua

  Generates a reader given a grammar and a parser to work with.

  The reader handles the coordination of parameterizing the grammar with the appropriate
  parser, and then using this parameterized grammar to read and interpret strings and/or
  files (or any other input, really).

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local reader = {}

function reader:new(grammar, parser)
  self.grammar = grammar(parser)
  return self
end

function reader:read_str(str)
  self.grammar:match(str)
end

function reader:read_file(src)
  -- TODO: We can be smarter about not reading the entire file at once here...
  local source = io.open(src, "r")
  self.grammar:match(source:read("*a"))
end

return reader
