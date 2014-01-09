-- grammar.lua
--
-- A simple LPeg grammar for scheme.
--
-- In order to be as flexible as possible, this grammar only parses tokens from
-- input. All interpretation and evaluation tasks are handled by the interpreter
-- which is provided as an argument to the main function returned by this
-- module.
--
-- Source Code Copyright (c) 2014, Joshua Ballanco.
--
-- License under the BSD 2-Clause License. See COPYING for full license details.


local lpeg = require("lpeg")
local P, R, S, V, C, Cg, Ct
      = lpeg.P, lpeg.R, lpeg.S, lpeg.V, lpeg.C, lpeg.Cg, lpeg.Ct

local grammar = {}
local G = {"Program"}

function grammar.geninterp(parser)
  setmetatable(G, {__index = lpeg})

  local interp = {}

  function interp.parsestr(string)
    lpeg.match(G, string)
  end

  function interp.parsefile(srcfile)
    -- TODO: We can be smarter about not reading the entire file at once here...
    local source = io.open(srcfile, "r")
    lpeg.match(G, source:read("*a"))
  end

  return interp
end

return grammar
