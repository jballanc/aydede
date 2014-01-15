--[[ main.lua

  The main Lua module for aydede.

  This module contains the `main` function that is called by the C wrapper after
  command-line arguments have been parsed. It accepts a single parameter, which is a table
  representing the parsed command-line arguments. Based on the values in the `opts`
  parameter, it then chooses the correct parser to load in the grammar, and loads the
  appropriate Scheme code to be run.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


function main(opts)
  local grammar = require("grammar")
  local reader

  if opts.debug then
    local debugparser = require("parser.debug")
    reader = grammar.genreader(debugparser)
  else
    print("Only debugging works at the moment...")
    os.exit(1)
  end

  if opts.evallist then
    for _,v in ipairs(opts.evallist) do
      reader.readstr(v)
    end
  elseif opts.srcfile then
    reader.readfile(opts.srcfile)
  else
    print("No source provided!")
  end
end
