require 'setup/core_ext'
require 'setup/constants'

module Setup
  # Common base class for all Setup build classes.
  # 
  class Base

    #
    attr :project

    #
    attr :config

    #
    attr_accessor :trial

    #
    attr_accessor :trace

    #
    attr_accessor :quiet

    #
    attr_accessor :force

    #
    attr_accessor :io

    #
    def initialize(project, configuration, options={})
      @project = project
      @config  = configuration

      options.each do |k,v|
        __send__("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    #
    def trial? ; @trial ; end

    #
    def trace? ; @trace ; end

    #
    def quiet? ; @quiet ; end

    #
    def force? ; @force ; end

    #
    def rootdir
      project.rootdir
    end

    # Shellout executation.
    def bash(*args_in)
      self.class.bash(*args_in)
    end

    # DEPRECATE
    alias_method :command, :bash

    # Shellout a ruby command.
    def ruby(*args)
      bash(config.rubyprog, *args)
    end

    # Ask a question of the user.
    #def ask(question, answers=nil)
    #  $stdout.puts "#{question}"
    #  $stdout.puts " [#{answers}] " if answers
    #  until inp = $stdin.gets ; sleep 1 ; end
    #  inp.strip
    #end

    #
    def trace_off #:yield:
      begin
        save, @trace = trace?, false
        yield
      ensure
        @trace = save
      end
    end

    # F I L E  U T I L I T I E S

    #
    def rm_f(path)
      io.puts "rm -f #{path}" if trace? or trial?
      return if trial?
      force_remove_file(path)
    end

    #
    def force_remove_file(path)
      begin
        remove_file(path)
      rescue
      end
    end

    #
    def remove_file(path)
      File.chmod 0777, path
      File.unlink(path)
    end

    #
    def rmdir(path)
      io.puts "rmdir #{path}" if trace? or trial?
      return if trial?
      Dir.rmdir(path)
    end

    class << self
      def trace? ; @trace ; end

      # Shellout executation.
      def bash(*args_in)
        $stderr.puts args_in.join(' ') if trace?
        args = args_in.map {|x|x.is_a?(Hash) && x.map {|k, v| [k.to_s, v] }.to_h || x }
        unless res = system(*args)
          $stderr.puts "ERROR: Shell command '#{args.join(' ')}' execution error"
          system(*args) or raise RuntimeError, "system(#{args.map{|a| a.inspect }.join(' ')}) failed"
        end
      end
    end
  end

  #
  class Error < StandardError
  end
end

require 'setup/concerns/specification'
::Gem::Specification.include(Setup::Concerns::Specification)
