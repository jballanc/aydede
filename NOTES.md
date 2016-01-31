# Notes

## Grammar

- use LPeg to generate grammar
- grammar only understands syntax, parsing and value generation is left to
  parser functions
- parser is seeded with the grammar:

```
parser = require('parser/aydede')
parser.grammar = require('grammar')
parser:parse(prgn)
```
- grammar is modular

## Parser

- essentially just a table with functions to be called as rules in the grammar
  match
- generates a tree (table of tables) of AST nodes

## Evaluator

- (optional) perform optimizing AST transforms
- stores and updates a table of bindings
- meta-circular w.r.t. Lua: performs evaluations using Lua and Lua libraries

## Macros

- parsing a macro generates an AST of syntax forms and stores in a table
- grammar for parser is updated with new rule based on `syntax-rules`
- parsing continues; when a macro rule is encountered, bindings on stored AST
  are updated and result is added to parser AST
