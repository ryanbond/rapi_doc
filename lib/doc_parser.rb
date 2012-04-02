module RapiDoc
  module DocParser
    # custom exception class
    class ParsingException < Exception;
    end
    # This method parses the doc
    def DocParser.parse_controller_doc(lines)
      current_api_block = nil
      current_scope = :none
      in_class = false
      class_block = nil
      function_blocks = []
      order = 1
      lines.each_with_index do |line, line_no|
        line.gsub!(/^ *#/, '') # strip the starting '#' on the line
        case line
          when /=begin apidoc/
            # if we get apidoc tag inside class definition, then they are for a method
            current_scope = !in_class ? :class : :function
            current_api_block = MethodDoc.new(current_scope, order)
          when /=end/
            if current_api_block.nil?
              raise ParsingException, "#{line_no} - No starttag for '=end' found"
            else
              case current_scope
                when :class
                  class_block = current_api_block
                when :function
                  function_blocks << current_api_block
                else
                  raise ParsingException, "logic error: unknown current scope #{current_scope}"
              end
              current_api_block = nil
              current_scope = :none
              order += 1
            end
          when /class/ # keep track of whether a resource or an api is being annotated
            in_class = true
          else
            if current_api_block # process ines only if they are apidoc comments
              current_scope = current_api_block.process_line(line, current_scope)
            end
        end
      end
      [class_block, function_blocks]
    end
  end
end
