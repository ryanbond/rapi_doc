require 'method_doc'

# ResourceDoc holds the information a resource contains. It parses the class header and also the 
# method documentation, which will be contained in MethodDoc.
class ResourceDoc
  
  attr_reader :name, :resource_location, :controller_name, :function_blocks, :class_block
  
  # Initializes RAPIDoc.
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
  
  
  # gets the name it is generated to
  def template_file_name
    File.join(['structure', "views", "#{controller_name}.html"])
  end
  
  # returns the location of the controller that is to be parsed
  def controller_location
    "#{::Rails.root.to_s}/app/controllers/#{controller_name}"
  end
  
  def get_binding
    binding
  end
  
  # parse the controller
  def parse_apidoc!
    current_api_block = nil
    current_scope = :none
    block_holder = []
    lineno = 0
    inclass = false
    
    File.open(controller_location).each do |line|
      if line =~ /=begin apidoc/
        current_scope = !inclass ? :class : :function
        current_api_block = MethodDoc.new(current_scope)
      elsif line =~ /=end/
        if current_api_block.nil?
          puts "#{controller_location}:#{lineno} - No starttag for =end found"
          exit
        elsif current_api_block.scope == :class
          @class_block = current_api_block
        elsif current_api_block.scope == :function
          @function_blocks << current_api_block
        end
        current_api_block = nil
        current_scope = :none
      elsif line =~ /class/
        inclass = true
      elsif line =~ /::response-end::/
        current_scope = :function
      elsif line =~ /::request-end::/
        current_scope = :function
      elsif current_scope == :response
        current_api_block.response += "#{line}"
      elsif current_scope == :request
        current_api_block.request += "#{line}"
      elsif current_scope == :class || current_scope == :function # check if we are looking at a api block
        # strip the # on the line
        #line = line[1..line.length].lstrip.rstrip
        # check if we are dealing with a variable
        # something in the format: # varname:: sometext
        if result = /(\w+)\:\:\s*(.+)/.match(line)
          if result[1] == "response" || result[1] == "request"
            puts "="*30
            puts "found response"
            puts "="*30; puts ""
            puts line
            current_scope = result[1].to_sym
          else
            current_api_block.add_variable(result[1], result[2])
          end
        else
          # add line to block
          current_api_block.content << line
        end
      end
      lineno += 1
    end

    puts "Generated #{name}.html"
  end
  
  def generate_view!(resources)
     @resources = resources
     @header_code = get_parsed_header unless @class_block.nil?
     function_blocks.each do |mb|
       @method_codes << get_parsed_method(mb)
     end
     # write it to a file
     template = ""
     File.open(resource_layout_file).each { |line| template << line }
     parsed = ERB.new(template).result(binding)
     File.open(File.join(File.dirname(__FILE__), '..', 'structure', 'views', 'apidoc', name + ".html"), 'w') { |file| file.write parsed }
  end


  def get_parsed_header
    template = ""
    File.open(File.join(File.dirname(__FILE__), '..', 'templates', '_resource_header.html.erb')).each { |line| template << line }

    puts "-"*30
    puts ">>> inside: get_parsed_header"
    puts ERB.new(template).result(@class_block.get_binding)
    puts "-"*30; puts ""

    return ERB.new(template).result(@class_block.get_binding)
  end


  def get_parsed_method(method_block)
    template = ""
    File.open(File.join(File.dirname(__FILE__), '..', 'templates', '_resource_method.html.erb')).each { |line| template << line }
    return ERB.new(template).result(method_block.get_binding)
  end
    
end
