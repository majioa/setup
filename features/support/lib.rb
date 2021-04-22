def space
   @space ||= cli.space
end

def cli
   @cli ||= Setup::CLI.new
   @cli.option_parser.default_argv << "-v" # NOTE to avoid errors
   @cli
end

def name_list
   @name_list ||= []
end

def names
   @names ||= []
end

def adopt_value value
   case value
   when ""
      nil
   else
      value
   end
end
