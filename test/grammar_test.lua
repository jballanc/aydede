--[[ test/grammar_test.lua

  Test suite to validate the Aydede LPeg grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


require("luaunit")

local P = require("lpeg").P
local grammar = require("grammar")

-- A mock parser that will fail for any function call by default
local pmock = {}
local function failed_call(table, key)
  return function (...)
    error("Unexpected call to method: "..tostring(key), 2)
  end
end
setmetatable(pmock, { __index = failed_call })


TestGrammar = {}

function TestGrammar:test_symbol()
  function pmock.symbol(str)
    assert_is(str, "foo")
  end

  local g = grammar(pmock)
  g[1] = "Symbol"

  P(g):match("foo")
end

LuaUnit:run()
