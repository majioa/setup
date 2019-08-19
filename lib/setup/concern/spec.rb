require 'erb'
require 'date'
require 'setup/concern'

# Spec generation service for setup.rb
module Setup::Concern::Spec
   def pkgname
      gemname&.gsub(/[_\.]+/, '-')
   end

   def gemname
      source&.name
   end

   def version
      source&.version
   end

   def license
      source&.license
   end

   def description
      @description ||= source&.description &&
                       source.description.gsub(/\n/, ' ')
                                         .gsub(/(.{1,#{80}})(\s+|$)/, "\\1\n")
                                         .gsub(/\*[\n ]/, "\n* ")
                                         .strip ||
                       source&.summary ||
                       gemname
   end

   def summary
      source&.summary ||
      description && description.gsub("\n", ' ').split(/[\.:!]/).first ||
      gemname
   end

   def url
      source&.url
   end

   def vcs
      @vcs ||= source&.url && source.url =~ /\.(github|gitlab)\.com\// && source.url.gsub(/\/?$/, '.git') || nil
   end

   def exefiles
#      require 'pry';binding.pry
      @exefiles ||= source&.exefiles&.sort_by do |x|
         x.size
      end&.sort do |x, _|
         source.name == x && 1 ||
         x.include?(source.name) && 1 || -1
      end || []
   end

   def exename
      exefiles.first
   end

   def exemask
      exefiles.count > 1 && "{#{exefiles.join(",")}}" || exefiles.first
   end

   def has_binary?
      source&.dlfiles&.any?
   end

   def is_gem?
      source&.is_a?(Setup::Source::Gem) || false
   end

   def has_docs?
      source&.rifiles&.any?
   end
end
