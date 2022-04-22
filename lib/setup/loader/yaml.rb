module Setup::Loader::YAML
   def yaml file
      spec = Gem::Specification.from_yaml(IO.read(file))

      file = Tempfile.new(spec.name)
      file.puts(spec.to_ruby)
      file.close
      res = app_file(file.path)
      file.unlink
      res
   rescue => e
      nil
   end
end

