--[[ util/table.lua

  Utility functions for working with tables.

  This is a collection of some useful methods for working with tabels in Lua.

  Copyright (c) 2015, Joshua Ballanco

  Licensed under the BSD 2-Clause License. See COPYING for full license details.

--]]


local util = {}

function util.merge(table, other)
  for k, v in pairs(other) do
    if not table[k] then
      table[k] = v
    end
  end
  return table
end

return util
