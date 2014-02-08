--[[ test/grammar_test.lua

  Test suite to validate the Aydede LPeg grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


require("luaunit")

local P = require("lpeg").P
local grammar = require("grammar")

-- A mock parser that will fail for any function call by default
local function failed_call(table, key)
  return function (...)
    error("Unexpected call to method: "..tostring(key), 2)
  end
end

local function mock(mock_funs)
  return setmetatable(mock_funs, { __index = failed_call })
end


TestGrammar = {}

function TestGrammar:test_string()
  p = mock({ string = function(str)
                        assert_is(str, "\"Hello, world\"")
                      end })

  local g = grammar(p)
  g[1] = "String"
  P(g):match("\"Hello, world\"")
end

function TestGrammar:test_escaped_quote_in_string()
  p = mock({ string = function(str)
                        assert_is(str, "\"I say, \\\"this works.\\\"\"")
                      end })

  local g = grammar(p)
  g[1] = "String"
  P(g):match("\"I say, \\\"this works.\\\"\"")
end

function TestGrammar:test_symbol()
  p = mock({ symbol = function(str)
                        assert_is(str, "foo")
                      end })

  local g = grammar(p)
  g[1] = "Symbol"

  P(g):match("foo")
end

function TestGrammar:test_decimal()
  p = mock({ number = function(str)
                        assert_is(str, "2.0")
                      end })

  local g = grammar(p)
  g[1] = "Number"

  P(g):match("2.0")
end

LuaUnit:setOutputType("TAP")
LuaUnit:run()
