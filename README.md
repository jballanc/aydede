# Aydede

This is a simplistic implementation of the R7RS small Scheme language on top of LuaJIT using LPeg to generate the grammar. The general approach follows the concept of the metacircular interpreter as presented in the "Structure and Interpretation of Computer Programs".


## Building

Both LuaJIT and LPeg have been vendored in with the project. LuaJIT is vendored as a git submodule, so before building you will need to check out the correct version of LuaJIT by running `git submodule update --init`. Also, the Makefile assumes that you have Clang installed to compile the C code. If not, you may need to edit the `CC` line in the Makefile.

From there, building should be as simple as running `make`.


# Copyright

Aydede Copyright (c) 2014, Joshua Ballanco.
Licensed under the BSD 2-Clause License. See COPYING for full license details.

LuaJIT Copyright (C) 2005-2013 Mike Pall. All rights reserved.
(See vendor/LuaJIT/COPYRIGHT for full details.)

LPeg Copyright © 2013 Lua.org, PUC-Rio.
(For full documentation and license terms, see: http://www.inf.puc-rio.br/~roberto/lpeg/)
