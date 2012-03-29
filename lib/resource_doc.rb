# encoding: utf-8
require 'method_doc'
require 'doc_parser'

module RapiDoc
  # ResourceDoc holds the information a resource contains. It parses the class header and also the 
  # method documentation, which will be contained in MethodDoc.
  class ResourceDoc
    
    attr_reader :name, :resource_location, :controller_name, :function_blocks, :class_block
    
    # Initializes ResourceDoc.
    def initialize(name, resource_location, controller_name, options = {})
      @name = name
      @standard_methods = options[:standard_methods] || [:put, :post, :get, :delete]
      @resource_location, @controller_name = resource_location, controller_name
      @function_blocks = []
      @method_codes = []
      @header_code = ""
      
      unless File.exist?(controller_location)
        raise "Unable to find or open controller. Make sure it's set properly in config/rapidoc/config.yml File: #{controller_location}"
      end
    end
    
    # returns the location of the controller that is to be parsed
    def controller_location
      # @resource_location
      @controller_location ||= "#{::Rails.root.to_s}/app/controllers/#{controller_name}"
    end
    
    # parse the controller
    def parse_apidoc!
      
      parser = DocParser.new
      order = 1
      File.open(controller_location).each_with_index do |line, line_no|
        case line
        when /=begin apidoc/
          parser.start(order)
        when /=end/
          if parser.current_api_block.nil?
            puts "#{controller_location}:#{line_no} - No starttag for '=end' found"
            exit
          else
            case parser.current_scope
            when :class
              @class_block = parser.current_api_block
            when :function
              @function_blocks << parser.current_api_block
            end
            parser.reset_current_scope_and_api_block
            order += 1
          end
        when /class/
          parser.in_class = true
        when /::response-end::/, /::request-end::/, /::output-end::/
          parser.current_scope = :function
        else
          parser.parse(line)
        end
      end
      
      get_parsed_output
    end

    def get_parsed_output
      @header_code = get_parsed_header unless @class_block.nil?
      @method_codes = function_blocks.each_with_index.collect { |mb, i| get_parsed_method(mb, i+1) }
      template = IO.read(config_dir(:layout_file))
      ERB.new(template).result(binding)
    end

    def get_parsed_header
      template = IO.read(template_dir('_resource_header.html.erb'))
      ERB.new(template).result(@class_block.get_binding)
    end

    def get_parsed_method(method_block, method_order)
      template = IO.read(template_dir('_resource_method.html.erb'))
      ERB.new(template).result(method_block.get_binding)
    end

  end
end
