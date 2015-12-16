module TaxGenerator
  # class that holds the helper methods used in the classes
  module ApplicationHelper
    delegate :app_logger,
             to: :'TaxGenerator::Application'

  module_function

    # returns the text from a nokogiri element by rejecting blank elements
    #
    # @param  [Nokogiri::Element]  element the nokogiri element that will select only children with content and returns their text
    #
    # @return [String]
    #
    # @api public
    def elements_with_content(element)
      if element.present?
        element.select { |elem| elem.content.present? }.join(&:text)
      else
        element
      end
    end

    # returns the root path of the gem
    #
    # @return [void]
    #
    # @api public
    def root
      File.expand_path(File.dirname(File.dirname(File.dirname(__dir__))))
    end

    # returns a Nokogiri XML document from a file
    #
    # @param  [String]  file_path the path to the xml file that will be parsed
    #
    # @return [void]
    #
    # @api public
    def nokogiri_xml(file_path)
      Nokogiri::XML(File.open(file_path), nil, 'UTF-8')
    end

    # creates directories from a list of arguments
    #
    # @param  [Array]  args the arguments that will be used as directory names and will create them
    #
    # @return [void]
    #
    # @api public
    def create_directories(*args)
      args.pmap do |argument|
        FileUtils.mkdir_p(argument) unless File.directory?(argument)
      end
    end

    # sets the exception handler for celluloid actors
    #
    #
    # @return [void]
    #
    # @api public
    def set_celluloid_exception_handling
      Celluloid.logger = app_logger
      Celluloid.task_class = Celluloid::TaskThread
      Celluloid.exception_handler do |ex|
        unless ex.is_a?(Interrupt)
          log_error(ex)
        end
      end
    end

    # Reads a file and interpretes it as ERB
    #
    # @param  [String]  file_path the file that will be read and interpreted as ERB
    #
    # @return [String]
    #
    # @api public
    def erb_template(file_path)
      template = ERB.new(File.read(file_path))
      template.filename = file_path
      template
    end

    # Displays a error with fatal log level
    # @see #format_error
    # @see #log_message
    #
    # @param  [Exception]  exception the exception that will be formatted and printed on screen
    #
    # @return [String]
    #
    # @api public
    def log_error(exception)
      message = format_error(exception)
      log_message(message, log_method: 'fatal')
    end

    # formats a exception to be displayed on screen
    #
    # @param  [String]  message the message that will be printed to the log file
    # @param  [Hash]  options the options used to determine how to log the message
    # @option options [String] :log_method The log method , by default debug
    #
    # @return [String]
    #
    # @api public
    def log_message(message, options = {})
      app_logger.send(options.fetch(:log_method, 'debug'), message)
    end

    # formats a exception to be displayed on screen
    #
    # @param  [Exception]  exception the exception that will be formatted and printed on screen
    #
    # @return [String]
    #
    # @api public
    def format_error(exception)
      message = "#{exception.class} (#{exception.respond_to?(:message) ? exception.message : exception.inspect}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << '  ' << exception.backtrace.join("\n  ") if exception.respond_to?(:backtrace)
      message
    end

    #  wrapper to execute a block and rescue from exception
    # @see #set_celluloid_exception_handling
    # @see #rescue_interrupt
    # @see #log_error
    #
    # @return [void]
    #
    # @api public
    def execute_with_rescue
      set_celluloid_exception_handling
      yield if block_given?
    rescue Interrupt
      rescue_interrupt
    rescue => error
      log_error(error)
    end

    #  rescues from a interrupt error and shows a message
    #
    # @return [void]
    #
    # @api public
    def rescue_interrupt
      `stty icanon echo`
      puts "\n Command was cancelled due to an Interrupt error."
    end
  end
end
