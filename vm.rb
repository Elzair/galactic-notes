## This class represents a variable stored in the virtual machine.
#class Variable
#  attr_accessor :name   # Name of variable
#  attr_accessor :value  # Value of variable
#  attr_accessor :type   # Type of variable
#  attr_accessor :base   # Is variable a base variable or reference variable?
#
#  # This method creates a new variable.
#  # - name: a String containing the name of the variable
#  # - value: an Object containg the value of the variable
#  #          (if value is a string, the variable is a reference)
#  # - type: a String containing the type of the variable
#  # - base: whether the variable is a base variable or reference variable
#  def initialize(name = "", value = nil, type = "NONE", base = false)
#    @name = name
#    @value = value
#    @type = type
#    @base = base
#  end
#end

# This class represents the virtual machine used to store & retrieve variables.
# It has several registers, a stack for computing roman numerals, and a Hash
# containing all the pre-defined variables.
class VM
  # This method creates a new VM object.
  # - err_class: the class name of the error to raise
  # - variables: a Hash representing the 'memory locations' to pre-load
  def initialize(err_class, variables = {})
    @err_class = err_class

    # Initialize opcodes
    @opcodes = [
      "CLR",  # Clear contents of register

      "DIV",  # Divide contents of second register by contents
              # of first register and store result in second register

      "HALT", # Halts Virtual Machine

      "LOAD", # Load string into print register

      "MOV",  # Move contents of memory location into register, or move 
              # contents of register into memory location, or move contents
              # of register into another register

      "MUL",  # Multiply contents of second register by contents
              # of first register and store result in second register

      "POP",  # Pop contents of stack register into another register

      "PUSH", # Push contents of register into stack register according
              # to the roman numeral guidelines listed below

      "RET"   # Return output string with $rr replaced by the contents
              # of the return register
    ]
    
    # Initialize registers
    @registers = {
      :ar => 0,  # General Purpose Register #1
      :br => 0,  # General Purpose Register #2
      :pr => "", # Print Register
      :rr => 0,  # Return Register
      :sr => 0   # Stack Register (used in PUSH & POP)
    }
    
    # Initialize variables in memory
    @variables = variables
  end

  # This method executes the input code.
  # - input: the code to execute
  def execute(input = "")
    # Split input into tokens by whitespace
    tokens = input.gsub(/\s+/m, " ").split(" ")

    # Ensure first token is a valid opcode
    if !@opcodes.include?(tokens[0])
      raise @err_class, "Invalid opcode, #{tokens[0]}, in statement: #{input}!"
    end

    case tokens[0]
    when "CLR"
      if tokens.length != 2 
        raise @err_class, "CLR Error: CLR has one operand!"
      end
      op1 = tokens[1][1...-1]
      if tokens[1][1] != "$" or !@registers.include?(op1)
        raise @err_class, "CLR Error: operand must be a valid register!"
      else
        @registers[op1] = 0
      end
    when "DIV"
      if tokens.length != 3
        raise @err_class, "Invalid DIV expression: #{input}!"
      elsif tokens[1][1] != "$" or tokens[2][1] != "$"
        raise @err_class, "DIV Error: both operands must be registers!"
      end
      reg1 = tokens[1][1...-1]
      reg2 = tokens[2][1...-1]
      if !@registers.include?(reg1)
        raise @err_class, "DIV Error: $#{reg1} is not a valid register!"
      elsif !@registers.include?(reg2)
        raise @err_class, "DIV Error: $#{reg2} is not a valid register!"
      elsif @registers[reg1] == 0
        raise @err_class, "DIV Error: Cannot divide by zero!"
      else
        @registers[reg2] /= @registers[reg1]
      end
    when "HALT"
    end
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
