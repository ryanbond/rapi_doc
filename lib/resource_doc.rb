# encoding: utf-8
require 'method_doc'
require 'doc_parser'

module RapiDoc
  # ResourceDoc holds the information a resource contains. It parses the class header and also the 
  # method documentation, which will be contained in MethodDoc.
  class ResourceDoc

    attr_reader :name, :resource_location, :controller_name, :class_block, :function_blocks

    # Initializes ResourceDoc.
    def initialize(name, resource_location, controller_location, options = {})
      @name = name
      @class_block = nil
      @function_blocks = []
      @method_codes = []
      @header_code = ""
      @standard_methods = options[:standard_methods] || [:put, :post, :get, :delete]
      @resource_location = resource_location
      @controller_location = controller_location
      @controller_name = File.basename(controller_location)
    end

    def get_binding
      binding
    end

    # parse the controller
    def parse_apidoc!
      lines = IO.readlines(@controller_location)
      begin
        @class_block, @function_blocks = DocParser.parse_controller_doc(lines)
      rescue DocParser::ParsingException => ex
        puts "error #{ex} while parsing #{@controller_location}"
        exit
      else
        class_template = IO.read(template_dir('_resource_header.html.erb'))
        method_template = IO.read(template_dir('_resource_method.html.erb'))
        @header_code = ERB.new(class_template).result(@class_block.get_binding) unless class_block.nil?
        @method_codes = @function_blocks.each_with_index.collect do |method_block, i|
          ERB.new(method_template).result(method_block.get_binding)
        end
        template = IO.read(config_dir(:layout_file))
        ERB.new(template).result(get_binding)
      end
    end

  end
end
