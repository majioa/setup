# Echoe based gemspec detection module
# Sample gems are: echoe
#
class Echoe
   def project= _
   end

   def author= value
      spec.authors << value
   end

   def url= url
      spec.homepage = url
   end

   def summary= value
      spec.summary = value
      spec.description ||= value
   end

   def dependencies= value
      value.each do |dep|
         spec.add_dependency *dep.split(/\s+/)
      end
   end

   def runtime_dependencies= value
      value.each do |dep|
         spec.add_runtime_dependency *dep.split(/\s+/)
      end
   end

   def development_dependencies= value
      value.each do |dep|
         spec.add_development_dependency *dep.split(/\s+/)
      end
   end

   def certificate_chain= value
      spec.signing_key = value
      spec.cert_chain << value
   end

   def licenses= value
      spec.licenses |= value
   end

   def rubygems_version= value
      if spec.respond_to? :required_rubygems_version=
         spec.required_rubygems_version = Gem::Requirement.new(value)
      end
   end

   def spec
      @spec ||= ::Gem::Specification.new
   end
   
   def rubyforge_name= _name
   end

   def description= desc
      spec.description = desc
   end

   def docs_host= url
      spec.metadata[:docs_host] = url
   end

   def rdoc_pattern= pattern
      spec.extra_rdoc_files.concat(Dir["*/**/*"].select {|f| f =~ /#{pattern}/ })
   end

   def test_pattern= pattern
      spec.test_files.concat(Dir["*/**/*"].select {|f| f =~ /#{pattern}/ })
   end

   def certificate_chain= chain
      spec.cert_chain = chain
   end

   def clean_pattern= pattern
      Dir["*/**/*"].select {|f| f =~ pattern }.each {|f| FileUtils.rm_f(f) }
   end

   def clean_pattern
      clean_pattern ||= []
   end

   def has_rdoc= _
   end

   def require_signed= _
   end

   def retain_gemspec= _
   end

   def need_tar_gz= _
   end

   def need_tgz= _
   end

   def extensions= _
   end

   def eval= _
   end

   def rdoc_template= _
   end

   def platform= _
   end

   protected

   DOC_FILTER = /CHANGELOG|LICENSE|README|\.rb$/i

   def initialize name
      spec.name = name
      spec.files = IO.read('Manifest').split("\n")
      spec.extra_rdoc_files = spec.files.select { |f| DOC_FILTER =~ f }
      vline = IO.read('CHANGELOG').split("\n").find { |x| /^\s*v/ =~ x }
      /v(?<version>[^ ]+)\. / =~ vline
      spec.version = version || "0.0"
      spec.rubygems_version = ">= 1.2"
      Dir.chdir('bin') do
         spec.executables = Dir['*']
      end if File.directory?('bin')
      yield(self)
   end
end
