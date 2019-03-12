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

      initialize_hooks

      options.each do |k,v|
        __send__("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    # Hooking into the setup process, use extension scripts
    # according to the name of the class. For instance to 
    # augment the behavior of the Installer, use:
    #
    #   .setup/installer.rb
    #
    def initialize_hooks
      file = META_EXTENSION_DIR + "/#{self.class.name.downcase}.rb"
      if File.exist?(file)
        script = File.read(file)
        (class << self; self; end).class_eval(script)
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
      $stderr.puts args_in.join(' ') if trace?
      args = args_in.map {|x|x.is_a?(Hash) && x.map {|k, v| [k.to_s, v] }.to_h || x }
      system(*args) or raise RuntimeError, "system(#{args.map{|a| a.inspect }.join(' ')}) failed"
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

  end

  #
  class Error < StandardError
  end

end

