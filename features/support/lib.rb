def space
   @space ||= cli.space
end

def cli
   @cli ||= Setup::CLI.new
end
