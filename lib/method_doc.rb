# This class holds methods about a doc.
class MethodDoc
  attr_accessor :scope, :content, :request, :response, :code
  
  def initialize(type)
    @scope = type
    @variables = []
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

    if name == "json"
      puts "Found json:"
      puts @json
    end
  end
  
  def get_binding
    binding
  end
end
