--[[ ast.lua

  Top-level module for AST elements.

  Other modules can require this module to get access to all of the various AST elements.

  Copyright (c) 2014, Joshua Ballanco.

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local ast = {}

ast.list = require("ast.list")

return ast
