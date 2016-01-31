--[[ helpers.lua

  Helper methods.

  This is a collection of some basic parse elements that are needed by almost
  every other grammar module. They should be merged at least once into the
  grammar table before the grammar is finalized.

  Copyright (c) 2015, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]

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
    if type(str) == "table" then
      if str[s] then
        assert_true(str[s] and str[s] > 0)
        str[s] = str[s] - 1
      end
    else
      assert_is(s, str)
    end
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

