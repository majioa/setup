require_relative 'lib/setup/version'

Gem::Specification.new do |spec|
   spec.name              = "setup"
   spec.version           = Setup::VERSION
   spec.authors           = ['Pavel "Malo" Skrylev', "7rans", "Minero Aoki"]
   spec.email             = ["majioa@altlinux.org", "transfire@gmail.com", "aamine@loveruby.net"]

   spec.summary           = %q{Setup.rb as a stand-alone application}
   spec.description       = <<~DESC
      Every Rubyist is aware of Minero Aoki's ever useful setup.rb script.
      It's how most of us used to install our Ruby programs before RubyGems
      came along. And it's still mighty useful in certain scenarios, not the least of which is the
      job of the distribution package managers. While still providing the usual setup.rb
      script that one can distribute with a project, Setup also works as a stand-alone
      application. Instead of distributing setup.rb with a package, just instruct your
      users to install Ruby Setup and use it instead.
      DESC
   spec.homepage          = "https://github.com/majioa/setup"
   spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

   spec.metadata["allowed_push_host"] = "https://rubygems.org"

   spec.metadata["homepage_uri"] = spec.homepage
   spec.metadata["source_code_uri"] = "https://github.com/majioa/setup"
   spec.metadata["changelog_uri"] = "https://github.com/majioa/setup/CHANGELOG.md"

   # Specify which files should be added to the gem when it is released.
   # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
   spec.files             = Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(features)/}) }
   end
   spec.bindir            = "exe"
   spec.executables       = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
   spec.require_paths     = ["lib"]
   spec.extra_rdoc_files  = ["LICENSE.txt", "README.md", "HISTORY.md"]
   spec.licenses = ["BSD-2-Clause", "BSD-2-Clause", "LGPL-2.0+"]
   spec.test_files = Dir.chdir(File.expand_path('..', __FILE__)) do
      `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(features)/}) }
   end

   spec.required_ruby_version = [ '>= 2.6.0' ]
   spec.add_development_dependency "bundler", "~> 2.0"
   spec.add_development_dependency "rake", "~> 12.0"
   spec.add_development_dependency "pry", "~> 0.13.1"
   spec.add_development_dependency "cucumber", "~> 5.2"
   spec.add_development_dependency "shoulda-matchers-cucumber", "~> 1.0", ">= 1.0.1"
end
