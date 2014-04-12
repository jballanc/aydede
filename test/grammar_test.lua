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

local function parse_rule(str)
  return function(s)
    assert_is(s, str)
  end
end

local function assert_parse(rule, str)
  local rule_tbl = {}
  rule_tbl["parse_"..rule:lower()] = parse_rule(str)

  p = mock(rule_tbl)
  local g = grammar(p)

  assert_true(g:match(str))
end

TestGrammar = {}

function TestGrammar:test_procedure_call()
  assert_parse("call", "(add 1 1)")
end

function TestGrammar:test_quotation()
  local rules = {}
  rules.parse_num = parse_rule("3")
  rules.parse_quotation = parse_rule("'3")
  assert_true(grammar(mock(rules)):match("'3"))
end

function TestGrammar:test_booleans()
  assert_parse("true", "#true")
  assert_parse("true", "#t")
  assert_parse("false", "#false")
  assert_parse("false", "#f")
end

function TestGrammar:test_vector()
  local rules = {}
  rules.parse_character = parse_rule("#\\a")
  rules.parse_num = parse_rule("2.3")
  rules.parse_true = parse_rule("#t")
  rules.parse_string = parse_rule("\"hello\"")
  rules.parse_bytevector = parse_rule("#u8(2 4 6)")
  rules.parse_vector = parse_rule("#(#\\a 2.3 #t \"hello\" #u8(2 4 6))")
  local p = mock(rules)
  local g = grammar(p)
  assert_true(g:match("#(#\\a 2.3 #t \"hello\" #u8(2 4 6))"))
end

function TestGrammar:test_other_datum_vectors()
  local rules = {}
  rules.parse_vector = parse_rule("#(#1#)")
  rules.parse_label = parse_rule("#1")
  local p = mock(rules)
  local g = grammar(p)
  assert_true(g:match("#(#1#)"))
end

function TestGrammar:test_abbreviations()
  local rules = {}
  rules.parse_string = parse_rule("\"test\"")
  rules.parse_abbreviation = parse_rule("'#(\"test\")")
  function rules.parse_vector(str)
    assert(str == "#(\"test\")" or str == "#('#(\"test\"))",
           "can't parse vector: "..str)
  end
  local p = mock(rules)
  local g = grammar(p)
  assert_true(g:match("#('#(\"test\"))"))
end

function TestGrammar:test_character()
  assert_parse("character", "#\\a")
  assert_parse("character", "#\\newline")
  assert_parse("character", "#\\xACB123")
end

function TestGrammar:test_string()
  assert_parse("string", "\"Hello, world\"")
end

function TestGrammar:test_escaped_quote_in_string()
  assert_parse("string", "\"I say, \\\"this works.\\\"\"")
end

function TestGrammar:test_multiline_string()
  assert_parse("string", "\"carried over multiple\\ \\n lines\"")
end

function TestGrammar:test_complex_string()
  assert_parse("string",
    [["This is a test with \"escaped quotes\", a line\\
    break, a \\xABC123 hex escape and \b more..."]])
end

function TestGrammar:test_bytevector()
  assert_parse("bytevector", "#u8(11)")
  assert_parse("bytevector", "#u8(4 8 15 16 23 42)")
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
  assert_parse("symbol", "foo")
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
