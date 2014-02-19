--[[ test/grammar_test.lua

  Test suite to validate the Aydede LPeg grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


require("luaunit")

local lp = require("lpeg")
local P = lp.P
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

local function assert_parse(rule, str)
  local rule_tbl = {}
  rule_tbl[rule:lower()] = function(s)
                             assert_is(s, str)
                           end
  p = mock(rule_tbl)
  local g = grammar(p)
  g[1] = rule
  P(g):match(str)
end

TestGrammar = {}

function TestGrammar:test_exponent()
  local g = grammar(mock({}))
  g[1] = 'Suffix'
  P(lp.Ct(g) / function(t)
                 local exp = t["exp"]
                 assert_is(exp["sign"], "+")
                 assert_is(exp["value"], "42")
               end):match("e+42")
end

function TestGrammar:test_string()
  assert_parse("String", "\"Hello, world\"")
end

function TestGrammar:test_escaped_quote_in_string()
  assert_parse("String", "\"I say, \\\"this works.\\\"\"")
end

function TestGrammar:test_symbol()
  assert_parse("Symbol", "foo")
end

function TestGrammar:test_decimal()
  assert_parse("Number", "2.0")
end

function TestGrammar:test_negative()
  assert_parse("Number", "-3.2")
end

LuaUnit:setOutputType("TAP")
LuaUnit:run()
