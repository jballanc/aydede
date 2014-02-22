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
local re = require("re")
local P, R, S, V, C, Cg, Ct, locale
      = lp.P, lp.R, lp.S, lp.V, lp.C, lp.Cg, lp.Ct, lp.locale

local function grammar(parse)
  local G

  -- Use locale for matching; generates rules: alnum, alpha, cntrl, digit, graph, lower,
  -- print, punct, space, upper, and xdigit
  re.updatelocale()

  G = re.compile([[
    -- Placeholder until I figure a better way to test...
    patts <- suffix / Symbol / Number / String

    suffix              <- {:exp: {| exp_marker sign exp_value |} :}
    exp_marker          <- [eE]
    explicit_sign       <- [+-]
    sign                <- {:sign: explicit_sign? :}
    exp_value           <- {:value: %digit+ :}

    open                <- [(]
    close               <- [)]
    quote               <- ["]
    not_quote           <- [^"]
    backslash           <- [\\]
    escaped_quote       <- backslash quote
    dot                 <- [.]
    minus               <- [-]

    -- Rules for the R7RS numeric tower
    exactness           <- ([#] ([iI] / [eE]))?
    bradix              <- [#] [bB]
    oradix              <- [#] [oO]
    radix               <- ([#] [dD])?
    xradix              <- [#] [xX]
    bdigit              <- [01]
    odigit              <- [0-7]

    -- Other basic elements
    initial             <- %alpha / special_initial
    special_initial     <- [!$%&*/:<=>?^_~]
    subsequent          <- initial / %digit / special_subsequent
    special_subsequent  <- explicit_sign / [.@]
    vertical_line       <- [|]
    xscalar             <- %xdigit+
    inline_hex_escape   <- backslash [x] xscalar [;]
    mnemonic_escape     <- backslash [abtnr]
    symbol_element      <- [^|\\] / inline_hex_escape / mnemonic_escape / "\\|"

    -- Parsing constructs
    String              <- { quote (escaped_quote / not_quote)* quote } -> parse_string
    Symbol              <- { %alpha %alnum* } -> parse_symbol
    Number              <- { sign %digit+ (dot %digit*)? } -> parse_number

    -- Simple forms
    Car                 <- Symbol
    Cdr                 <- List+ / Symbol / Number
    List                <- {|
                              open %space*
                              {:car: Car :} %space+
                              {:cdr: Cdr :} %space*
                              close
                           |} -> parse_list
    Program             <- {| List+ |}
  ]], parse)

  return G
end

return grammar
