module Setup::Loader::Yaml
   def yaml file
      spec = Gem::Specification.from_yaml(IO.read(file))

      file = Tempfile.create(spec.name)
      file.puts(spec.to_ruby)
      file.close
      app_file(file.path)
   rescue => e
      nil
   end
end

