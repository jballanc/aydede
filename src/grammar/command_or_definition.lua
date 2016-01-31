--[[ grammar/command_or_definition.lua

  Grammar definitions for the R7RS "CommandOrDefinition" rule.

  This module pulls together all the subsequent definitions that make up the R7RS
  "CommandOrDefinition" rule and merge them into a single grammar table.

  Copyright (c) 2015, Joshua Ballanco

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local tu = require("util/table")
local lp = require("lpeg")
local V = lp.V

local command_or_definition = {
  "CommandOrDefinition",
  CommandOrDefinition = V("Definition")
}

local definition = require("grammar/definition")
tu.merge(command_or_definition, definition)

return command_or_definition
