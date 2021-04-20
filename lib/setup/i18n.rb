require 'setup/version'

module Setup::I18n
   class << self
      def locale_trees
         @locale_trees ||= {}
      end

      def default_locale
         @default_locale ||= locales.sort do |x, y|
            x == "en_US.UTF-8" && -1 || y == "en_US.UTF-8" && 1 || 0
         end.first
      end

      def locales
         @locales ||= Dir[File.join(File.dirname(__FILE__), "..", "..", "locale", "*.yaml")].map do |file|
            File.basename(file, ".yaml")
         end
      end

      def defaulted_locales
         @defaulted_locales ||= locales.map { |locale| locale == default_locale && "" || locale }
      end

      def locale_tree locale
         return locale_trees[locale] if locale_trees[locale]

         file = File.join(File.dirname(__FILE__), "..", "..", "locale", "#{locale}.yaml")

         YAML.load(IO.read(file))
      end

      def t! path, options = {}
         parts = path.to_s.split(".")
         locale = options[:locale].blank? && default_locale || options[:locale]
         #binding.pry
         line = parts.reduce(locale_tree(locale)) { |r, part| [ r[part] ].flatten.first }

         line.gsub(/%\w+/) do |str|
            /%(?<name>\w+)/ =~ str

            if options[:binding].local_variable_defined?(name)
               options[:binding].local_variable_get(name)
            elsif options[:binding].instance_variable_defined?("@#{name}")
               options[:binding].instance_variable_get(:"@#{name}")
            end
         end
      end

      def t path, options = {}
         t!(path, options)
      rescue NoMethodError
         nil
      end
   end
end
