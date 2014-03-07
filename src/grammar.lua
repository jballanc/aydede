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
  -- Use locale for matching; generates rules: alnum, alpha, cntrl, digit, graph, lower,
  -- print, punct, space, upper, and xdigit
  re.updatelocale()

  return re.compile([[
    -- "Program" is the top-level construct in Scheme, but for now we're using it to proxy
    -- to other forms for testing...
    Program             <- CommandOrDefinition

    -- TODO: need to add the "...OrDefinition" part. For now just proxying through to
    -- forms we want to test...
    CommandOrDefinition <- Command
    Command             <- Expression

    -- "Expression" encompases most valid forms, including everything that counts as a
    -- "Datum" for processing by the REPL. More elements will be added to this list as
    -- more of the grammar is defined.
    Expression          <- Literal  -- TODO: Literal should come after Symbol
                                    -- ...just here to test suffix for now
                         / Symbol   -- Synonymous with "Identifier"

    Literal             <- SelfEvaluating

    SelfEvaluating      <- String
                         / Number

    explicit_sign       <- [+-]

    open                <- [(]
    close               <- [)]
    slash               <- [/]
    backslash           <- [\\]
    quote               <- ["]
    not_quote           <- [^"]
    escaped_quote       <- backslash quote
    dot                 <- [.]
    minus               <- [-]

    -- Rules for the R7RS numeric tower
    Number              <- bnum / onum / num / xnum
    bnum                <- { {| {:prefix: bprefix :} {:num: bcomplex :} |} } -> parse_bnum
    onum                <- { {| {:prefix: oprefix :} {:num: ocomplex :} |} } -> parse_onum
    num                 <- { {| {:prefix: prefix :} {:num: complex :} |} } -> parse_num
    xnum                <- { {| {:prefix: xprefix :} {:num: xcomplex :} |} } -> parse_xnum
    -- For a true full numeric tower, we would have to implement all the variations on
    -- complex number forms. For now, we only consider simple real numbers.
    bcomplex            <- breal
    ocomplex            <- oreal
    complex             <- real
    xcomplex            <- xreal
    breal               <- {| {:sign: sign :} bureal |} / infnan
    oreal               <- {| {:sign: sign :} oureal |} / infnan
    real                <- {| {:sign: sign :} ureal |} / infnan
    xreal               <- {| {:sign: sign :} xureal |} / infnan
    bureal              <- {:numerator: buint :} slash {:denominator: buint :}
                         / {:whole: buint :}
    oureal              <- {:numerator: ouint :} slash {:denominator: ouint :}
                         / {:whole: ouint :}
    ureal               <- decimal
                         / {:numerator: uint :} slash {:denominator: uint :}
                         / {:whole: uint :}
    xureal              <- {:numerator: xuint :} slash {:denominator: xuint :}
                         / {:whole: xuint :}
    decimal             <- {:whole: digit+ :} dot {:fraction: digit+ :} suffix
                         / dot {:fraction: digit+ :} suffix
                         / {:whole: uint :} suffix
    buint               <- bdigit +
    ouint               <- odigit +
    uint                <- digit +
    xuint               <- xdigit +
    bprefix             <- {:radix: bradix :} {:exactness: exactness :}
                         / {:exactness: exactness :} {:radix: bradix :}
    oprefix             <- {:radix: oradix :} {:exactness: exactness :}
                         / {:exactness: exactness :} {:radix: oradix :}
    prefix              <- {:radix: radix :} {:exactness: exactness :}
                         / {:exactness: exactness :} {:radix: radix :}
    xprefix             <- {:radix: xradix :} {:exactness: exactness :}
                         / {:exactness: exactness :} {:radix: xradix :}
    inf                 <- {:sign: explicit_sign :} [iI][nN][fF] dot '0'
    nan                 <- {:sign: explicit_sign :} [nN][aA][nN] dot '0'
    infnan              <- {|
                             {:inf: inf :}
                           / {:nan: nan :}
                           |}
    suffix              <- {:exp:
                             exp_marker
                             {|
                               {:sign: sign :}
                               {:value: digit+ :}
                             |}
                           :}?
    exp_marker          <- [eE]
    sign                <- explicit_sign?
    exactness           <- ([#] ([iI] / [eE]))?
    bradix              <- [#] [bB]
    oradix              <- [#] [oO]
    radix               <- ([#] [dD])?
    xradix              <- [#] [xX]
    bdigit              <- [01]
    odigit              <- [0-7]
    digit               <- %digit
    xdigit              <- %xdigit

    -- Other basic elements
    initial             <- %alpha / special_initial
    special_initial     <- [!$%&*/:<=>?^_~]
    subsequent          <- initial / digit / special_subsequent
    special_subsequent  <- explicit_sign / [.@]
    vertical_line       <- [|]
    xscalar             <- xdigit+
    inline_hex_escape   <- backslash [x] xscalar [;]
    mnemonic_escape     <- backslash [abtnr]
    symbol_element      <- [^|\\] / inline_hex_escape / mnemonic_escape / "\\|"

    -- Parsing constructs
    String              <- { quote (escaped_quote / not_quote)* quote } -> parse_string
    Symbol              <- { %alpha %alnum* } -> parse_symbol

    -- Simple forms
    Car                 <- Symbol
    Cdr                 <- List+ / Symbol / Number
    List                <- {|
                              open %space*
                              {:car: Car :} %space+
                              {:cdr: Cdr :} %space*
                              close
                           |} -> parse_list
  ]], parse)
end

return grammar
