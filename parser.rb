
# This class represents an LL(2) [1] Recursive Descent Parser for
# the Galactic Notes program.  
class Parser
  # This method creates a new Parser object.
  # - node_class: the class name of the Abstract Syntax Tree's node
  # - err_class: the class name of the error to raise
  def initialize(node_class, err_class)
    @node_class = node_class
    @err_class = err_class
  end

  # This method parses the tokens from the lexical analyzer
  # and returns an Abstract Syntax Tree of the result. 
  # - input: a String containing the user's input
  # - ast: an Object representing the Abstract Syntax Tree to use
  # returns: an Object containing the result as an Abstract Syntax Tree
  def parse(tokens = [], ast = nil)
    # Initialize needed variables to a known state
    @ast = ast
    @tokens = tokens
    @pos = 0

    # Parse high level statement
    statement

    # Return result
    return @ast
  end

  # This method matches the top level rule for the Galactic Notes input grammar.
  def statement
    # Get first token
    curr_token = get_next_token

    # Use curr_token to determine which rule to use
    if curr_token.type == "HOW"
      how
    elsif curr_token.type == "QUIT"
      quit
    elsif curr_token.type == "VARIABLE"
      assign(curr_token)
    else
      raise @err_class, "I don't know what you're talking about!" 
    end
  end

  # This method parses a statement to quit the program.
  def quit
    node = @node_class.new("QUIT", nil, [], true, true)
    @ast.insert(node)
    handle_end
  end

  # This method parses a query statement.
  def how
    curr_token = get_next_token
    if curr_token.type == "MANY"
      how_many
    elsif curr_token.type == "MUCH"
      how_much
    else
      raise @err_class, "I don't know what you're talking about!"
      #raise @err_class, "It's in how!"
    end
  end

  # This method parses the statement "How many Credits is [ numeral ] commodity ?".
  def how_many
    # Validate the sentence begins with "How many Credits is".
    curr_token = get_next_token
    if curr_token.type != "CREDITS"
      raise @err_class, "How many of what?"
    end
    curr_token = get_next_token
    if curr_token.type != "IS"
      raise @err_class, "How many Credits do what?"
    end

    # Insert HOWMANY & GALNUMBER nodes into AST
    curr_node = @node_class.new("HOWMANY", nil, [], true, false)
    @ast.insert(curr_node)
    curr_node = @node_class.new("GALNUMBER", nil, [], false, false)
    @ast.insert(curr_node, @ast.seek({:name => "HOWMANY"}))
    
    # Validate the rest of the sentence
    prev_token = nil
    curr_token = get_next_token
    while curr_token.type != "QUESTION"
      if curr_token.type != "VARIABLE"
        raise @err_class, "I don't know what #{curr_token.value} is!"
      end
      prev_token = curr_token
      curr_token = get_next_token
      if curr_token.type == "QUESTION"
        prev_token.type = "COMMODITY"
        curr_node = @node_class.new("COMMODITY", prev_token.value, [], false, true)
        @ast.insert(curr_node, @ast.seek({:name => "HOWMANY"}))
      else
        prev_token.type = "GALNUM"
        curr_node = @node_class.new("GALNUMERAL", prev_token.value, [], false, true)
        @ast.insert(curr_node, @ast.seek({:name => "GALNUMBER"}))
      end
    end

    handle_end
  end

  # This method parses the statement "How much is [ numeral ] ?".
  def how_much
    # Make sure statement begins with "How much is"
    if get_next_token.type != "IS"
      raise @err_class, "I don't know what you're talking about!"
    end

    # Add HOWMUCH & GALNUMBER nodes to @ast
    curr_node = @node_class.new("HOWMUCH", nil, [], true, false)
    @ast.insert(curr_node)
    curr_node = @node_class.new("GALNUMBER", nil, [], false, false)
    @ast.insert(curr_node, @ast.seek({:name => "HOWMUCH"}))

    # Make sure the rest of the statement is one or more Galactic Numerals
    curr_token = get_next_token
    while curr_token.type != "QUESTION"
      if curr_token.type == "VARIABLE"
        curr_token.type = "GALNUM"
        curr_node = @node_class.new("GALNUMERAL", curr_token.value, [], false, true)
        @ast.insert(curr_node, @ast.seek({:name => "GALNUMBER"}))
      else
        raise @err_class, "I don't know what " + curr_token.value + " is!"
      end
      curr_token = get_next_token
    end

    handle_end
  end

  # This method handles assignment statements.
  # - curr_token: a Token object representing the current token
  def assign(curr_token = nil)
    # First handle errors
    if curr_token == nil
      raise @err_class, "I don't know what you're talking about!"
    elsif curr_token.type != "VARIABLE"
      raise @err_class, "I don't know what #{curr_token.value} is!"
    end

    # Add ASSIGN node to @ast
    curr_node = @node_class.new("ASSIGN", nil, [], true, false)
    @ast.insert(curr_node)

    # The first variable in an assignment statement should always be
    # a Galactic Numeral, so we can declare it here.
    curr_token.type = "GALNUM"
    curr_node = @node_class.new("GALNUMERAL", curr_token.value, [], false, true)

    # Use assign_variable if only one variable is present
    # Use assign_value if otherwise
    curr_token = get_next_token
    if curr_token.type == "IS"
      # Insert curr_node here so we don't have to pass it to assign_variable()
      @ast.insert(curr_node, @ast.seek({:name => "ASSIGN"}))
      assign_variable(curr_token)
    elsif curr_token.type == "VARIABLE"
      # Create GALNUMBER @node_class to contain all GALNUMERAL nodes & insert both it
      # and the first GALNUMERAL node into @ast
      prev_node = curr_node
      curr_node = @node_class.new("GALNUMBER", nil, [], false, false)
      @ast.insert(curr_node, @ast.seek({:name => "ASSIGN"}))
      @ast.insert(prev_node, @ast.seek({:name => "GALNUMBER"}))
      assign_value(curr_token)
    else
      raise @err_class, "I don't know what you're talking about!"
    end
  end

  # This method parses the statement "variable is defined_numeral".
  # - curr_token: a Token object representing the current token
  def assign_variable(curr_token = nil)
    # First handle errors
    if curr_token == nil
      raise @err_class, "I need a variable!"
    end

    curr_token = get_next_token
    if curr_token.type == "VARIABLE"
      curr_token.type = "GALNUM"
      curr_node = @node_class.new("GALNUMERAL", curr_token.value, [], false, true)
      @ast.insert(curr_node, @ast.seek({:name => "ASSIGN"}))
    else
      raise @err_class, "I don't know what #{curr_token.value} is!"
    end

    handle_end
  end

  # This method parses the statement "{ defined_numeral }+ commodity IS number" 
  # - curr_token: a Token object representing the current token
  def assign_value(curr_token = nil)
    # First handler errors.
    if curr_token.type != "VARIABLE"
      raise @err_class, "I need a variable!"
    end
   
    # Validate up until the "IS" token
    while curr_token.type != "IS"
      prev_token = curr_token
      curr_token = get_next_token
      if curr_token.type == "VARIABLE"
        prev_token.type = "GALNUM"
        curr_node = @node_class.new("GALNUMERAL", prev_token.value, [], false, true)
        @ast.insert(curr_node, @ast.seek({:name => "GALNUMBER"}))
      elsif curr_token.type == "IS"
        prev_token.type = "COMMODITY"
        curr_node = @node_class.new("COMMODITY", prev_token.value, [], false, true)
        @ast.insert(curr_node, @ast.seek({:name => "ASSIGN"}))
      else
        raise @err_class, "assign_value I don't know what #{curr_token.value} is!"
      end
    end

    curr_token = get_next_token
    if curr_token.type != "NUMBER"
      raise @err_class, "I don't know what you're talking about!"
    else
      curr_node = @node_class.new("NUMBER", curr_token.value, [], false, true)
      @ast.insert(curr_node, @ast.seek({:name => "ASSIGN"}))
    end

    if get_next_token.type != "CREDITS"
      raise @err_class, "I don't know what you're talking about!"
    end

    handle_end
  end

  # This method handles the end of an input statement
  def handle_end
    if get_next_token.type != "EOL"
      raise @err_class, "I don't know what you're talking about!"
    end
  end

  # This is a convenience method to getting the next token from @lexer.
  def get_next_token
    token = @tokens[@pos]
    @pos += 1
    return token
  end
end

# [1] Since several statements accept a series of numerals followed by 
# a commodity variable it is not possible to determine whether a VARIABLE 
# returned by the lexical analyzer is really of type NUMERAL or COMMODITY
# without seeing if the next token starts the next part of the statement.
