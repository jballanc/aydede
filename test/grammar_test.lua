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
  if (key:sub(1,6) == "parse_") then
    return function (...)
      error("Unexpected call to method: "..tostring(key), 2)
    end
  end
end

local function mock(mock_funs)
  return setmetatable(mock_funs, { __index = failed_call })
end

local function assert_parse(rule, str)
  local rule_tbl = {}
  local function parse(s)
    assert_is(s, str)
  end

  rule_tbl["parse_"..rule:lower()] = parse

  p = mock(rule_tbl)
  local g = grammar(p)

  assert_true(g:match(str))
end

TestGrammar = {}

function TestGrammar:test_booleans()
  assert_parse("true", "#true")
  assert_parse("true", "#t")
  assert_parse("false", "#false")
  assert_parse("false", "#f")
end

function TestGrammar:test_character()
  assert_parse("character", "#\\a")
  assert_parse("character", "#\\newline")
  assert_parse("character", "#\\xACB123")
end

function TestGrammar:test_exponent()
  local p = {}
  function p.parse_num(s, p, t)
    assert_is(s, "-11.23e42")
    assert_is(p, 1)
    assert_is_table(t)

    assert_is(t["prefix"], "")
    assert_is_table(t["num"])

    local num = t["num"]
    assert_is(num["sign"], "-")
    assert_is(num["whole"], "11")
    assert_is(num["fraction"], "23")
    assert_is_table(num["exp"])

    local exp = num["exp"]
    assert_is(exp["sign"], "")
    assert_is(exp["value"], "42")
  end

  local g = grammar(mock(p))
  assert_true(g:match("-11.23e42"))
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
  assert_parse("num", "2.0")
end

function TestGrammar:test_negative()
  assert_parse("num", "-3.2")
end

function TestGrammar:test_hexnum()
  assert_parse("xnum", "#xAF92")
end

function TestGrammar:test_octinfnan()
  assert_parse("onum", "#o-inf.0")
end

function TestGrammar:test_sci_notation()
  assert_parse("num", "6.0223E23")
end

LuaUnit:setOutputType("TAP")
LuaUnit:run()
