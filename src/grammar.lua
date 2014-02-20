--[[ grammar.lua

  A simple LPeg grammar for scheme.

  In order to be as flexible as possible, this grammar only parses tokens from
  input. All interpretation and evaluation tasks are handled by the interpreter
  which is provided as an argument to the main function returned by this
  module.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local lp = require("lpeg")
local P, R, S, V, C, Cg, Ct, locale
      = lp.P, lp.R, lp.S, lp.V, lp.C, lp.Cg, lp.Ct, lp.locale

local function grammar(parse)
  local G = {"Program"}

  -- Use locale for matching; generates rules: alnum, alpha, cntrl, digit, graph, lower,
  -- print, punct, space, upper, and xdigit
  G = locale(G)

  G.open = P"("
  G.close = P")"
  G.quote = P"\""
  G.backslash = P"\\"
  G.escaped_quote = V"backslash" * V"quote"
  G.dot = P"."
  G.minus = P"-"

  -- Constructs from the R7RS formal grammar
  -- Numbers in bases 2, 8, 10, and 16
  G.suffix = Cg(Ct(V"exp_marker" * V"sign" * V"exp_value"), "exp")
  G.exp_value = Cg(V"digit"^1, "value")
  G.exp_marker = S"eE"
  G.sign = Cg(S"+-"^-1, "sign")
  G.exactness = P(P"#i" + P"#e" + P"#I" + P"#E")^-1
  G.bradix = P"#b" + P"#B"
  G.oradix = P"#o" + P"#O"
  G.radix = P(P"#d" + P"#D")^-1
  G.xradix = P"#x" + P"#X"
  G.bdigit = S"01"
  G.odigit = R"07"
  -- Other basic elements
  G.initial = V"alpha" + V"special_initial"
  G.special_initial = S"!$%&*/:<=>?^_~"
  G.subsequent = V"initial" + V"digit" + V"special_subsequent"
  G.explicit_sign = S"+-"
  G.special_subsequent = V"explicit_sign" + S".@"
  G.vertical_line = P"|"
  G.xscalar = V"xdigit"^1
  G.inline_hex_escape = P"\\x" * V"xscalar" * P";"
  G.mnemonic_escape = P"\\a" + P"\\b" + P"\\t" + P"\\n" + P"\\r"
  G.symbol_element = -S"|\\" + V"inline_hex_escape" + V"mnemonic_escape" + P"\\|"


  -- Parsing constructs
  G.String = C(V"quote" * P(-V"quote"^0 + V"escaped_quote") * V"quote") / parse.string
  G.Symbol = C(V"alpha" * V"alnum"^0) / parse.symbol
  G.Number = V"minus"^-1 * P(V"digit"^1) * P(V"dot" * V"digit"^0)^-1 / parse.number

  G.Car = V"Symbol"
  G.Cdr = V"List"^1 + V"Symbol" + V"Number"
  G.List = Ct(V"open" * P" "^0 * Cg(V"Car", "car") * P" "^0
              * Cg(V"Cdr", "cdr") * P" "^0 * V"close") / parse.list

  G.Program = Ct(V"List"^1)

  return G
end

return grammar
