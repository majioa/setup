require 'setup'

class Setup::Deps
   attr_reader :project

   REQS = {
      'lib' => {
         proc { |target| target.source.compilable? }               => proc { |this| this.deps_ruby_version },
         proc { |target| target.source.valid? }                    => proc { |this, target| this.deps_dyno(target.source, 'lib', :dsl) },
      },
      'bin' => {
         proc { |target| target.public_executables.any? }          => proc { |this, target| this.deps_ruby_exec(target) },
         proc { |target| target.source.exefiles.any? &&
                         target.source.is_a?(Setup::Source::Gem) } => proc { |this, target| this.deps_dyno(target.source, 'bin') },
      },
      'doc' => {
         proc { |target| target.source.is_a?(Setup::Source::Gem) } => proc { |this, target| this.deps_dyno(target.source, 'doc') },
      },
      'devel' => {
         proc { |target| target.source.inctree.any? &&
                         target.source.is_a?(Setup::Source::Gem) } => proc { |this, target| this.deps_dyno(target.source, 'devel') },
      }
   }

   PROVS = {
      'lib' => {
         proc { |target| target.source.is_a?(Setup::Source::Gem) } => proc { |this, target| this.deps_gem_ext(target.source) },
      },
      'bin' => {
         proc { |target| target.public_executables.any? }          => proc { |this, target| this.deps_execs(target) },
      },
   }

   def targets
      if name = project.config.current_package_name
         project.targets.select { |target| target.source.has_name?(name) }
      else
         project.targets
      end
   end

   def target_provs target, sets_in = nil
      sets = sets_in && [ sets_in ].flatten || PROVS.keys

      PROVS.select { |set, _| sets.include?(set) }.map do |set, data|
         provs = data.map do |cond_in, prov_in|
            cond = cond_in.is_a?(Proc) ? cond_in[target] : cond_in
            cond && (prov_in.is_a?(Proc) && prov_in[self, target] || prov_in) || []
         end.flatten

         [ set, provs ]
      end.to_h
   end

   def target_reqs target, sets_in = nil
      sets = sets_in && [ sets_in ].flatten || REQS.keys

      #require 'pry'; binding.pry
      REQS.select { |set, _| sets.include?(set) }.map do |set, data|
         reqs = data.map do |cond_in, req_in|
            cond = cond_in.is_a?(Proc) ? cond_in[target] : cond_in
            cond && (req_in.is_a?(Proc) && req_in[self, target] || req_in) || []
         end.flatten

         [ set, reqs.uniq ]
      end.to_h
   end

   ## deps
   def deps_gem_dsl dsl
      list = []

      dsl.deps.each do |dep|
         self.class.to_rpm(dep.requirement).map do |a, b|
            list << "ruby-gem(#{dep.name}) #{a} #{b}"
         end
      end

      ruby = dsl.ruby[:type]
      ruby_version = dsl.ruby[:version]
      rubygems_version = dsl.rubygems[:version]

      list << self.class.to_rpm(ruby_version).map { |a, b| "#{ruby} #{a} #{b}" }
      list << "rubygems #{rubygems_version}"
   end

   def deps_ruby_version
      "ruby(#{RbConfig::CONFIG['ruby_version']})"
   end

   def deps_gem source
      [ "gem(#{source.name})", source.version ].compact.join(' = ')
   end

   def deps_gem_ext source
      %w(gem ruby-gem rubygem).map do |kind|
         "#{kind}(#{source.name}) = #{source.version}"
      end
   end

   def deps_dyno source, set, kind = nil
      root = project.config.dep_sources[set]
      name = (root[source.name] || root[nil]).first
      if name == 'auto'
         kind == :dsl && deps_gem_dsl(source.dsl) || deps_gem(source)
      else
         project.select_source(name).map do |source|
            deps_gem_dsl(source.dsl)
         end
      end
   end

   def deps_ruby_exec target
      target.public_executables.map do |file|
         File.join(target.root, file)
      end.map do |file|
         if File.symlink?(file)
            realfile = File.readlink(file)
            IO.read(File.join(target.root, realfile), mode: 'rb').split("\n").first
         elsif File.exist?(file)
            IO.read(file, mode: 'rb').split("\n").first
         end
      end.compact.uniq.map do |line|
         if match = /#!\s*(?<exec>\S+)/.match(line)
            match[:exec]
         else
            $stderr.puts "Invalid shebang line '#{line}'"
            nil
         end
      end.uniq
   end

   def deps_execs target
      target.public_executables
   end

   # common
   def deps type, set = nil
      $stderr.puts "* #{type} ->"

      method = method("target_#{type}")

      deps = targets.map do |target|
         $stderr.puts "  - [#{target.source.name}]"

         target_deps = method[target, set].each do |set, deps|
            if !deps.empty?
               $stderr.puts "    [#{set}]:"
               deps.each do |dep|
                  $stderr.puts "      #{dep}"
               end
            end
         end

         [ target.source.name, target_deps ]
      end.to_h
   end

   def reqs
      deps 'reqs', project.config.current_set
   end

   def provs
      deps 'provs', project.config.current_set
   end

   class << self
      def to_rpm req
         req.requirements.reduce({}) do |s, r|
            ver = Gem::Version.new("#{r[1]}".gsub(/x/, '0'))

            tmp = case r[0]
                  when "~>"
                     {'>=' => ver.release, '<' => ver.bump}
                  when "!="
                     {'>' => ver.release}
                  else
                     {r[0] => ver}
                  end

            s.merge(tmp)
         end
      end
   end

   protected

   def initialize project: raise, options: {}
      @project = project
      @options = options
   end
end
