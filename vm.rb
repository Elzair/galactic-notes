# This class represents a variable stored in the virtual machine.
class Variable
  attr_accessor :name
  attr_accessor :value
  attr_accessor :type
  attr_accessor :base
  def initialize(name = "", value = nil, type = "NONE", base = false)
    @name = name
    @value = value
    @type = type
    @base = base
  end
end

class VMError < RuntimeError
end

# This class represents the virtual machine used to store & retrieve variables.
class VM
  def initialize(variables = {})
    roman_numerals = { 
      "I" => Variable.new("I", 1, "NUMERAL", true),
      "V" => Variable.new("V", 5, "NUMERAL", true),
      "X" => Variable.new("X", 10, "NUMERAL", true),
      "L" => Variable.new("L", 50, "NUMERAL", true),
      "C" => Variable.new("C", 100, "NUMERAL", true),
      "D" => Variable.new("D", 500, "NUMERAL", true),
      "M" => Variable.new("M", 1000, "NUMERAL", true)
    }
    # Make sure roman numerals cannot be overwritten!
    @variables = variables.merge(roman_numerals)
    # Load initial currency value
    @variables["Credits"] = Variable.new("Credits", 1, "CURRENCY", true)
  end

  # This method retrieves the variable indicated by name.
  def load(name = "")
    if @variables.has_key?(name)
      return @variables[name]
    else
      raise VMError, name + " is not defined!"
    end
  end

  # This method returns all variables of a given type.
  def load_type(type = "")
    vars = []
    @variables.values.each do |var|
      if var.type == type
        vars.push(var)
      end
    end
  end

  # This method stores a new variable in the VM
  def store(variable = nil)
    if @variables.has_key?(variable.name)
      raise VMError, variable.name + " already exists!"
    else
      @variables[variable.name] = variable
    end
  end
end
