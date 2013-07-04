
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
              # of register into another register, or move constant value into
              # register, or move constant value into memory location 
              # and set @flags[:nr_change] to true if contents of $nr changed

      "MUL",  # Multiply contents of second register by contents
              # of first register and store result in second register

      "POP",  # Pop contents of $sr into another register

      "PUSH", # Push contents of $nr onto $sr according
              # to the roman numeral guidelines listed below

      "RET"   # Return output string with $rr replaced by the contents
              # of the return register
    ]
    
    # Initialize registers
    @registers = {
      :ar => 0,  # General Purpose Register #1
      :br => 0,  # General Purpose Register #2
      :nr => 0,  # Numeral Register (used as input for PUSH)
      :pr => "", # Print Register
      :rr => 0,  # Return Register
      :sr => 0   # Stack Register (used in PUSH & POP)
    }

    # Initialize CPU flags
    @flags = {
      :halt => false,        # When true, the Virtual Machine halts
      :nr_change => false,   # Whether or not to apply special rules to PUSH
      :output => false,      # Set when VM has output to return
    }
    
    # Initialize variables in memory
    if !variables.respond_to?(:has_key?)
      raise @err_class, "Input variables must be in the form of a Hash!"
    else
      @variables = variables
    end
  end

  # This method executes the inputted statement on the Virtual Machine.
  # - input: a String containing the code to execute
  def execute(input = "")
    # Ensure input is a nonempty string
    if !input.is_a?(String)
      raise @err_class, "Input must be a string!"
    elsif input == ""
      raise @err_class, "Empty input!" 
    end

    # Set @flags[:output] to false at beginning of statement
    @flags[:output] = false

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
      op1 = tokens[1][1..-1].to_sym
      if tokens[1][0] != "$" or !@registers.has_key?(op1)
        raise @err_class, "CLR Error: operand must be a valid register!"
      else
        @registers[op1] = 0
      end
    when "DIV"
      if tokens.length != 3
        raise @err_class, "Invalid DIV expression: #{input}!"
      elsif tokens[1][0] != "$" or tokens[2][0] != "$"
        raise @err_class, "DIV Error: both operands must be registers!"
      end
      op1 = tokens[1][1..-1].to_sym
      op2 = tokens[2][1..-1].to_sym
      if !@registers.has_key?(op1)
        raise @err_class, "DIV Error: $#{op1} is not a valid register!"
      elsif !@registers.has_key?(op2)
        raise @err_class, "DIV Error: $#{op2} is not a valid register!"
      elsif @registers[op1] == 0
        raise @err_class, "DIV Error: Cannot divide by zero!"
      elsif op2 == :nr or op2 == :pr or op2 == :sr
        raise @err_class, "DIV Error: Cannot use $#{op2} as 2nd operand!"
      else
        @registers[op2] /= @registers[op1]
      end
    when "HALT"
      if tokens.length != 1
        raise @err_class, "HALT Error: Halt takes no operands!"
      else
        @flags[:halt] = true
      end
    when "LOAD"
      if tokens.length < 2 or tokens[1][0] != "'" or tokens[-1][-1] != "'"
        raise @err_class, "LOAD Error: LOAD requires a valid input string!"
      # Load everything between the single quotes into the print register
      else
        @registers[:pr] = input[5..-1].strip[1..-2]
      end
    when "MOV"
      if tokens.length != 3
        raise @err_class, "MOV Error: MOV requires two operands!"
      end
      op1_type = tokens[1][0] # register, variable or number
      # If op1 is a number, do not strip leading character
      op1 = op1_type =~ /[[:digit:]]/ ? tokens[1] : tokens[1][1..-1].to_sym
      op2_type = tokens[2][0] # register or variable
      op2 = tokens[2][1..-1].to_sym
      # Ensure op1 is a number, variable or register & op2 is a variable or register 
      if op1_type != "$" and op2_type != "$"
        raise @err_class, "MOV Error: at least one operand must be a register!"
      elsif op2_type != "$" and op2_type != "%"
        raise @err_class, "MOV Error: 2nd operand must be a register or variable!"
      elsif op1_type != "$" and op1_type != "%" and op1_type !~ /[[:digit:]]/
        raise @err_class, "MOV Error: 1st operand must be a register, variable or number!"
      # Ensure op1 is a valid register or variable
      # Since the Virtual Machine initializes a memory location by moving the
      # contents of a register into it, we only need to validate op2 if
      # it is a register
      elsif op1_type == "$" and !@registers.has_key?(op1)
        raise @err_class, "MOV Error: $#{op1} is an invalid register!"
      elsif op1_type == "%" and !@variables.has_key?(op1)
        raise @err_class, "MOV Error: %#{op1} is an invalid variable!"
      elsif op1_type =~ /[[:digit:]]/ and !is_numeric?(op1)
        raise @err_class, "MOV Error: $#{op1} is an invalid number!"
      elsif op2_type == "$" and !@registers.has_key?(op2)
        raise @err_class, "MOV Error: (2) $#{op2} is an invalid register!"
      # Proceed if everything looks good
      else
        # First get value from op1
        if op1_type == "$"
          tmp = @registers[op1]
        elsif op1_type == "%"
          tmp = @variables[op1]
        else
          tmp = op1.to_f
        end
        # Then store value in op2
        if op2_type == "$"
          # If op2 is $nr, set @flags[:nr_change] to true if $nr changes
          old_nr = 0
          if op2 == :nr
            old_nr = @registers[:nr]
          end
          @registers[op2] = tmp
          if op2 == :nr and @registers[:nr] != old_nr
            @flags[:nr_change] = true
          end
        else
          @variables[op2] = tmp
        end
      end
    when "MUL"
      if tokens.length != 3
        raise @err_class, "MUL Error: MUL takes two operands!"
      elsif tokens[1][0] != "$" or tokens[2][0] != "$"
        raise @err_class, "MUL Error: both operands must be registers!"
      end
      op1 = tokens[1][1..-1].to_sym
      op2 = tokens[2][1..-1].to_sym
      if !@registers.has_key?(op1)
        raise @err_class, "MUL Error: $#{op1} is an invalid register!"
      elsif !@registers.has_key?(op2)
        raise @err_class, "MUL Error: $#{op2} is an invalid register!"
      elsif op2 == "nr" or op2 == "pr" or op2 == "sr"
        raise @err_class, "MUL Error: 2nd operand cannot be $#{op2}!"
      else
        @registers[op2] *= @registers[op1]
      end
    when "PUSH"
      if tokens.length != 1
        raise @err_class, "PUSH Error: PUSH takes no operands!" 
      else
        # Trigger Roman Numeral rules if a new numeral was pushed to $nr 
        if @flags[:nr_change]
          # If $nr < $sr, subtract $nr from $sr, add $nr to $sr otherwise
          if @registers[:nr] < @registers[:sr]
            @registers[:sr] -= @registers[:nr]
          else
            @registers[:sr] += @registers[:nr]
          end
          # Unset :nr_change flag
          @flags[:nr_change] = false
        else
          @registers[:sr] += @registers[:nr]
        end
      end
    when "POP"
      if tokens.length != 2
        raise @err_class, "POP Error: POP takes one operand!"
      elsif tokens[1][0] != "$"
        raise @err_class, "POP Error: operand must be a register!"
      end
      op1 = tokens[1][1..-1].to_sym
      if !@registers.has_key?(op1)
        raise @err_class, "POP Error: $#{op1} is not a valid register!"
      # Make sure op1 is a usable register
      elsif op1 == :nr or op1 == :pr or op1 == :sr
        raise @err_class, "POP Error: Cannot POP $sr onto $#{op1}!"
      else
        @registers[op1] = @registers[:sr]
      end
    when "RET"
      if tokens.length != 1
        raise @err_class, "RET Error: RET takes no operands!"
      else
        #@registers[:pr].sub(/\$rr/, "#{@registers[:rr]}")
        @registers[:pr].gsub!("\$rr", @registers[:rr].to_s)
        @flags[:output] = true   
      end
    end
  end

  # This method outputs whether or not the Virtual Machine has halted.
  # returns: whether or not the CPU halted
  def halt?
    return @flags[:halt]
  end

  # This method outputs whether or not the Virtual Machine has
  # any output to return.
  # returns: whether or not the CPU has output
  def has_output?
    return @flags[:output]
  end

  # This method returns the output of the Virtual Machine.
  # returns: a String containing the output
  def output
    return @registers[:pr]
  end

  # This is a helper method to determine if an input token is a valid number.
  def is_numeric?(n = 0)
    true if Float(n) rescue false
  end

  # This method returns the entire state of the Virtual Machine.
  # returns: an Array of Hashes containing flags, registers & variables
  def dump_state
    return [ @flags, @registers, @variables ]
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
