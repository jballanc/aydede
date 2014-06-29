--[[ test/grammar_test.lua

  Test suite to validate the Aydede LPeg grammar.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


require("luaunit")

local lp = require("lpeg")
local P = lp.P
local grammar = require("grammar")

-- ### Helper Functions ###
--
-- A mock parser that will fail for any function call by default
local function failed_call(table, key)
  if (key:sub(1,6) == "parse_") then
    return function (...)
      error("Unexpected call to method: "..tostring(key), 2)
    end
  end
end

-- Convenience for creating a mock from a set of functions
local function mock(mock_funs)
  return setmetatable(mock_funs, { __index = failed_call })
end

-- Simple HOF for use with mocks to generate parse tests
local function parse_rule(str)
  return function(s)
    assert_is(s, str)
  end
end

-- Takes a table of rule/match pairs and turns it into a grammar test using mocks
local function assert_parse_rules(rules_tbl, str)
  local default_rule = table.remove(rules_tbl, 1)
  if default_rule then
    rules_tbl[default_rule] = str
  end

  local rules = {}
  for rule, match in pairs(rules_tbl) do
    rules["parse_"..rule] = parse_rule(match)
  end

  local p = mock(rules)
  local g = grammar(p)
  assert_true(g:match(str))
end

-- Convenience for generating a single rule test
local function assert_parse_rule(rule, str)
  assert_parse_rules({rule}, str)
end


-- ### Tests ###

TestGrammar = {}

function TestGrammar:test_lambda()
  assert_parse_rules({
    "lambda",
    symbol = "add",
    num = "1",
    call = "(add 1 1)"
  },
  "(lambda () (add 1 1))")
end

function TestGrammar:test_procedure_call()
  assert_parse_rules({
    "call",
    symbol = "add",
    num = "1",
  },
  "(add 1 1)")
end

function TestGrammar:test_quotation()
  assert_parse_rules({
    "quotation",
    num = "3"
  },
  "'3")
end

function TestGrammar:test_booleans()
  assert_parse_rule("true", "#true")
  assert_parse_rule("true", "#t")
  assert_parse_rule("false", "#false")
  assert_parse_rule("false", "#f")
end

function TestGrammar:test_vector()
  assert_parse_rules({
    "vector",
    character = "#\\a",
    num = "2.3",
    string = "\"hello\"",
    bytevector = "#u8(2 4 6)",
  },
  "#(#\\a 2.3 \"hello\" #u8(2 4 6))")
end

function TestGrammar:test_other_datum_vectors()
  assert_parse_rules({
    "vector",
    label = "#1"
  },
  "#(#1#)")
end

function TestGrammar:test_abbreviations()
  assert_parse_rules({
    "vector",
    num = "1",
    abbreviation = "'1"
  },
  "#('1)")
end

function TestGrammar:test_character()
  assert_parse_rule("character", "#\\a")
  assert_parse_rule("character", "#\\newline")
  assert_parse_rule("character", "#\\xACB123")
end

function TestGrammar:test_string()
  assert_parse_rule("string", "\"Hello, world\"")
end

function TestGrammar:test_escaped_quote_in_string()
  assert_parse_rule("string", "\"I say, \\\"this works.\\\"\"")
end

function TestGrammar:test_multiline_string()
  assert_parse_rule("string", "\"carried over multiple\\ \\n lines\"")
end

function TestGrammar:test_complex_string()
  assert_parse_rule("string",
    [["This is a test with \"escaped quotes\", a line\\
    break, a \\xABC123 hex escape and \b more..."]])
end

function TestGrammar:test_bytevector()
  assert_parse_rule("bytevector", "#u8(11)")
  assert_parse_rule("bytevector", "#u8(4 8 15 16 23 42)")
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

function TestGrammar:test_symbol()
  assert_parse_rule("symbol", "foo")
end

function TestGrammar:test_decimal()
  assert_parse_rule("num", "2.0")
end

function TestGrammar:test_negative()
  assert_parse_rule("num", "-3.2")
end

function TestGrammar:test_hexnum()
  assert_parse_rule("xnum", "#xAF92")
end

function TestGrammar:test_octinfnan()
  assert_parse_rule("onum", "#o-inf.0")
end

function TestGrammar:test_sci_notation()
  assert_parse_rule("num", "6.0223E23")
end

LuaUnit:setOutputType("TAP")
LuaUnit:run()
