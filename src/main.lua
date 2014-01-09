function main(opts)
  local grammar = require("grammar")
  local interp

  if opts.debug then
    local debugparser = require("parser.debug")
    interp = grammar.geninterp(debugparser)
  else
    print("Only debugging works at the moment...")
    os.exit(1)
  end

  if opts.evallist then
    for _,v in ipairs(opts.evallist) do
      interp.parsestr(v)
    end
  elseif opts.srcfile then
    interp.parsefile(opts.srcfile)
  else
    print("No source provided!")
  end
end
