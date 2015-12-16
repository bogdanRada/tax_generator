require_relative './helpers/application_helper'
module TaxGenerator
  # class used run the processsor
  #
  # @!attribute opts
  #   @return [Slop::Options] the options that are used for command line access
  #
  class Application
    include TaxGenerator::ApplicationHelper

    attr_reader :opts

    # method used to initialize the application, by initializing the options for command line
    # access
    #
    #
    # @return [void]
    #
    # @api public
    def initialize
      @opts = Slop::Options.new
      @opts.banner = 'usage: tax_generator [options] ...'
    end

    #  receives a list of options that are used to determine the input files and output and input folders
    #
    # @param  [Hash]  options the options that are used for command line access
    #
    # @see #execute_with_rescue
    # @see TaxGenerator::Processor#new
    # @see TaxGenerator::Processor#work
    #
    # @return [void]
    #
    # @api public
    def run(options = {})
      execute_with_rescue do
        options = options.present? ? options : parse_options
        processor = TaxGenerator::Processor.new(options)
        processor.work
      end
    end

    #  returns the logger used to log messages and errors
    #
    # @return [Logger]
    #
    # @api public
    def self.app_logger
      @logger ||= Logger.new($stdout)
    end

    #  returns the options list as a hash after parsing command line arguments
    #
    # @return [Hash]
    #
    # @api public
    def parse_options
      setup_command_line_options
      parser = Slop::Parser.new(@opts)
      result = parser.parse(ARGV.dup)
      result.to_hash
    end

    #  sets the directory options for command line access
    #
    # @return [void]
    #
    # @api public
    def directory_options
      @opts.separator ''
      @opts.separator 'Directory options:'
      @opts.string '-i', '--input_dir', 'The input directory ', default: "#{root}/data/input"
      @opts.string '-o', '--output_dir', 'The ouput directory', default: "#{root}/data/output"
    end

    #  sets the file options for command line access
    #
    # @return [void]
    #
    # @api public
    def file_options
      @opts.separator ''
      @opts.separator 'Extra options:'
      @opts.string '-t', '--taxonomy_filename', 'The taxonomy file name', default: 'taxonomy.xml'
      @opts.string '-d', '--destinations_filename', 'The destinations file name', default: 'destinations.xml'
    end

    #  sets the version of the gem available to be displayed from command line
    #
    # @return [void]
    #
    # @api public
    def setup_version
      @opts.on '--version', 'The destinations file name' do
        puts TaxGenerator.gem_version
        exit
      end
    end

    #  sets the help menu for command line access
    #
    # @return [void]
    #
    # @api public
    def setup_help
      @opts.on '--help', 'print the help' do
        puts @opts
        exit
      end
    end

    #  sets the command line options
    #
    # @return [void]
    #
    # @api public
    def setup_command_line_options
      directory_options
      file_options
      setup_version
      setup_help
    end
  end
end
