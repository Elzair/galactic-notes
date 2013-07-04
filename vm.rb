# This class represents a variable stored in the virtual machine.
class Variable
  attr_accessor :name   # Name of variable
  attr_accessor :value  # Value of variable
  attr_accessor :type   # Type of variable
  attr_accessor :base   # Is variable a base variable or reference variable?

  # This method creates a new variable.
  # - name: a String containing the name of the variable
  # - value: an Object containg the value of the variable
  #          (if value is a string, the variable is a reference)
  # - type: a String containing the type of the variable
  # - base: whether the variable is a base variable or reference variable
  def initialize(name = "", value = nil, type = "NONE", base = false)
    @name = name
    @value = value
    @type = type
    @base = base
  end
end

# This class represents the virtual machine used to store & retrieve variables.
# It has several registers, a stack for computing roman numerals, and a Hash
# containing all the pre-defined variables.
class VM
  # This method creates a new VM object.
  # - err_class: the class name of the error to raise
  # - variables: a Hash representing the 'memory locations' to pre-load
  def initialize(err_class, variables = {})
    @err_class = err_class
    #roman_numerals = { 
    #  "I" => Variable.new("I", 1, "NUMERAL", true),
    #  "V" => Variable.new("V", 5, "NUMERAL", true),
    #  "X" => Variable.new("X", 10, "NUMERAL", true),
    #  "L" => Variable.new("L", 50, "NUMERAL", true),
    #  "C" => Variable.new("C", 100, "NUMERAL", true),
    #  "D" => Variable.new("D", 500, "NUMERAL", true),
    #  "M" => Variable.new("M", 1000, "NUMERAL", true)
    #}
    # Make sure roman numerals cannot be overwritten!
    #@variables = variables.merge(roman_numerals)
  end

  # This method retrieves the variable indicated by name.
  # - name: a String containing the name of the variable to load
  def load(name = "")
    if @variables.has_key?(name)
      return @variables[name]
    else
      raise @err_class, name + " is not defined!"
    end
  end

  # This method returns all variables of a given type.
  # - type: a String containing the type of variable to return
  def load_type(type = "")
    vars = []
    @variables.values.each do |var|
      if var.type == type
        vars.push(var)
      end
    end
  end

  # This method stores a new variable in the VM.
  # - variable: a Variable object containing the information to store
  def store(variable = nil)
    if @variables.has_key?(variable.name)
      raise @err_class, variable.name + " already exists!"
    else
      @variables[variable.name] = variable
    end
  end
end
