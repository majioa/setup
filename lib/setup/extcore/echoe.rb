class Echoe
   def project= _
   end

   def author= value
      spec.authors << value
   end

   def summary= value
      spec.summary = value
      spec.description ||= value
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

   def require_signed
   end

   def retain_gemspec= _
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

   protected

   DOC_FILTER = /CHANGELOG|LICENSE|README|\.rb$/i

   def initialize name
      spec.name = name
      spec.files = IO.read('Manifest').split("\n")
      spec.extra_rdoc_files = spec.files.select { |f| DOC_FILTER =~ f }
      vline = IO.read('CHANGELOG').split("\n").find { |x| /^v/ =~ x }
      /v(?<version>[^ ]+)\. / =~ vline
      spec.version = version
      spec.rubygems_version = ">= 1.2"
      yield(self)
   end
end
