# Class to read in asciidoc-bib options from command-line, and 
# store results in an accessible form.
#
# Copyright (c) Peter Lane, 2013.
# Released under Open Works License, 0.9.2

require 'optparse'

module AsciidocBib
  class Options
    attr_reader :bibfile, :filename, :links, :style

    def initialize(program_name = 'asciidoc-bib')
      @bibfile = ''
      @links = true
      @style = AsciidocBib::Styles.default_style

      options = OptionParser.new do |opts|
        opts.banner = "Usage: #{program_name} filename"
        opts.on("-h", "--help", "help message") do |v|
          puts "#{program_name} #{AsciidocBib::VERSION}"
          puts
          puts options
          puts
          puts "All styles available through CSL are supported."
          puts "The default style is 'apa'."
          exit!
        end
        opts.on("-b", "--bibfile FILE", "location of bib file") do |v|
          @bibfile = v
        end
        opts.on("-n", "--no-links", "do not add internal links") do |v|
          @links = false
        end
        opts.on("-s", "--style STYLE", "reference style") do |v|
          @style = v
        end
        opts.on("-v", "--version", "show version") do |v|
          puts "#{program_name} version #{AsciidocBib::VERSION}"
          exit!
        end
      end

      begin
        options.parse!
      rescue 
        puts options
        exit!
      end

      # unless specified by caller, try to find the bibliography
      if @bibfile.empty?
        @bibfile = AsciidocBib::FileHandlers.find_bibliography "."
        if @bibfile.empty?
          @bibfile = AsciidocBib::FileHandlers.find_bibliography "#{ENV['HOME']}/Documents"
        end
      end
      if @bibfile.empty?
        puts "Error: could not find a bibliography file"
        exit
      end
      unless AsciidocBib::Styles.valid? @style
        puts "Error: style #{@style} was not one of the available styles"
        exit
      end

      if ARGV.length == 1
        @filename = ARGV[0]
      else
        puts "Error: a single file to convert must be given"
        exit
      end

      puts "Reading biblio: #{@bibfile}"
      puts "Reference style: #{@style}"
    end
  end
end

