# Aydede

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

**Aydede** is an implementation of the R7RS small Scheme language on top of the
LuaJIT runtime. It makes use of LPeg for specifying the grammar and follows the
general design of the metacircular interpreter described in "Structure and
Interpretation of Computer Programs".

What makes **Aydede** unique is how it handles interpretation. The interpreter
is parameterized at runtime based on the command-line arguments provided. This
means that, for example, passing the `--ast` argument will tell **Aydede** to
use the AST-Printing interpreter that only dumps the AST to STDOUT and then
quits.


## Building

Both LuaJIT and LPeg have been vendored in with the project. LuaJIT is vendored
as a git submodule, so before building you will need to check out the correct
version of LuaJIT by running `git submodule update --init`. Also, the Makefile
assumes that you have Clang installed to compile the C code. If not, you may
need to edit the `CC` line in the Makefile.

From there, building should be as simple as running `make`.


# Copyright

Aydede Copyright (c) 2014-2016, Joshua Ballanco.

Licensed under the BSD 2-Clause License. See COPYING for full license details.

---

The following 3rd party Open Source projects have been used in part or in full.
License details for each can be found in the appropriate text file in the
`licenses` directory.

* LuaJIT Copyright (C) 2005-2013 Mike Pall. All rights reserved.

* LPeg Copyright © 2013 Lua.org, PUC-Rio.

* Luaunit Copyright (c) 2005,2007,2012, Philippe Fremy <phil at freehackers dot org>

* Chibi Scheme, Copyright (c) 2009-2012 Alex Shinn

