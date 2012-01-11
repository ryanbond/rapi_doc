module RapiDoc
  # This class holds the methods that parse the doc
  class DocParser
    attr_accessor :current_api_block, :current_scope, :line_no, :in_class

    def initialize
      @current_api_block = nil
      @current_scope = :none
      @line_no = 0
      @in_class = false
    end

    def start(order)
      @current_scope = !in_class ? :class : :function
      @current_api_block = MethodDoc.new(current_scope, order)
    end

    def reset_current_scope_and_api_block
      @current_api_block = nil
      @current_scope = :none
    end

    def parse(line)
      case current_scope
      when :response
        @current_api_block.response += strip_line(line)
      when :request
        @current_api_block.request += strip_line(line)
      when :output
        @current_api_block.append_output strip_line(line)
      when :class, :function
        if result = /(\w+)\:\:\s*(.+)/.match(line)
          if result[1] == "response" || result[1] == "request"
            @current_scope = result[1].to_sym
          elsif result[1] == "output"
            @current_scope = result[1].to_sym
            @current_api_block.add_output(result[1], result[2])
          else
            @current_api_block.add_variable(result[1], result[2])
          end
        else
          # add line to block
          @current_api_block.content << strip_line(line)
        end
      end
    end

    # strip the '#' on the line
    def strip_line(line)
      line[1..line.length]
    end
  end
end