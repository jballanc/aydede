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
