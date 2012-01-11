module RapiDoc
  # This class holds methods about a doc.
  class MethodDoc
    attr_accessor :scope, :content, :request, :response, :code, :outputs, :variables, :method_order
    
    def initialize(type, order)
      @scope = type
      @method_order = order
      @variables = []
      @outputs = []
      @content = ""
      @code = ""
      @request = ""
      @response = ""
    end
    
    
    def add_variable(name, value)
      if name == "param"
        @variables << value
        return
      end

      eval("@#{name}= \"#{value}\"")
      self.class.class_eval { attr_accessor name.to_sym }
    end

    def add_output(name, value)
      if name == 'output'
        @outputs << eval("{#{value}: ''}")
        return
      end
    end

    def append_output(value)
      last_output_key = @outputs.last.keys[0]
      @outputs.last[last_output_key] += ERB::Util.html_escape(value)
    end

    def get_binding
      binding
    end
  end
end