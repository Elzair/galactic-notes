require './lexer.rb'

class Node
  attr_accessor :name
  attr_accessor :value
  attr_accessor :children
  attr_accessor :is_root
  attr_accessor :is_leaf

  def initialize(name = "", value = nil, children = [], is_root = false, is_leaf = false)
    @name = name
    @value = value
    @children = children
    @is_root = is_root
    @is_leaf = is_leaf
  end

  def to_s(show_children = true)
    # Since @value can be nil nil does not have a to_s method
    # we need to specify that some other way 
    out = "[ " + @name + " "
    if @value == nil
      out = out + "nil "
    else
      out = out + @value.to_s + " "
    end
    # If show_children is true, show child nodes in brackets
    if show_children == true
      if @children == []
        out = out + "[] "
      else
        children.each do |child|
          out = out + child.to_s
        end
      end
    end
    out = out + @is_root.to_s + " " + @is_leaf.to_s + " ] "
    return out
  end
end

class AST
  attr_accessor :root

  def initialize(root = nil)
    @root = root
  end

  def insert(node = nil, curr_node = @root)
    # Ensure node is a valid node
    if node == nil or !node.is_a?(Node)
      raise ParseError, "Error! Invalid node!"
    end

    # If AST is empty, insert node at root 
    if curr_node == @root and @root == nil
      if node.is_root == true
        @root = node
      else
        raise ParseError, "Invalid root node: " + node.to_s
      end
    elsif curr_node == nil
      raise ParseError, "Cannot add a subnode to a nil node!"
    # If AST is nonempty, add node as a child node to curr_node
    else
      insert_child_node(node, curr_node)
    end 
  end

  def insert_child_node(node, curr_node)
    if node.is_root == false
      if curr_node.is_leaf == false
        curr_node.children.push(node)
      else
        raise ParseError, "Cannot add child node to leaf node!"
      end
    else
      raise ParseError, "Cannot insert more than one root node!"
    end
  end

  def seek(attributes)
    result = seek_r(attributes, @root)
    if result == nil
      raise ParseError, "No match found for " + attributes.to_s + "!"
    else
      return result
    end
  end

  def seek_r(attributes = {}, curr_node = @root)
    # Examine all keys/value pairs in attributes & ensure they are all
    # equivalent to a corresponding attribute in curr_node
    match = true
    attributes.keys.each do |key|
      if !Node.public_instance_methods.include?(key) || curr_node.send(key) != attributes[key]
        match = false 
      end
    end
    if match == true
      return curr_node
    # Return nil if curr_node is a leaf node
    elsif curr_node.is_leaf == true 
      return nil
    else
      # If a child node (or one of its children) contains a match, then
      # return it. Otherwise, examine the next child node.
      curr_node.children.each do |child|
        result = seek_r(attributes, child)
        if result != nil
          return result 
        end
      end
      # Return nil if no child node (or subnode) matches
      return nil
    end
  end

  def to_s
    output = []
    output << @root.to_s(false)
    next_level = @root.children
    # Repeat until no node at the current depth has children
    while next_level != []
      row_output = []
      curr_level = next_level
      next_level = []
      # Display all nodes at the current depth & get their children
      curr_level.each do |node|
        row_output << node.to_s(false)
        next_level = next_level + node.children
      end
      output << row_output.join(" ")
    end
    return output.join("\n")
  end
end

class ParseError < RuntimeError
end

# This class is an LL(2) [1] Recursive Descent Parser for the Galactic Notes program.  
class Parser
  # This method creates a new Parser object.
  # - lexer: an object representing the lexical analyzer to use
  # - ignore_case: whether or not input is case sensitive
  def initialize(lexer = nil, ignore_case = false)
    # Ensure @lexer is a valid lexical analyzer
    if lexer == nil or !lexer.respond_to?("next_token")
      raise ParseError, "I need a valid lexical analyzer!"
    else
      @lexer = lexer
    end
    @ignore_case = ignore_case
    @history = []
  end

  # This method parses and handles input from the user
  # - input: a String containing the user's input
  def parse_input(input = "")
    # Initialize needed variables to a known state
    if @ignore_case
      input = input.upcase
    end
    @output = AST.new
    @history.push(input)
    @input = input
    @tokens = []
    @pos = 0

    # Process input
    statement

    # Return result
    return @output
  end

  # This method matches the top level rule for the Galactic Notes input grammar.
  def statement
    # Get first token
    curr_token = get_next_token(true, false)

    # Use curr_token to determine which rule to use
    if curr_token.type == "HOW"
      @tokens.push(curr_token)
      how
    elsif curr_token.type == "QUIT"
      @tokens.push(curr_token)
      quit
    elsif curr_token.type == "VARIABLE"
      assign(curr_token)
    else
      raise ParseError, "I don't know what you're talking about!" 
    end
  end

  # This method parses a statement to quit the program.
  def quit
    node = Node.new("QUIT", nil, [], true, true)
    @output.insert(node)
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
      raise ParseError, "I don't know what you're talking about!"
    end
  end

  # This method parses the statement "How many Credits is [ numeral ] commodity ?".
  def how_many
    # Validate the sentence begins with "How many Credits is".
    curr_token = get_next_token
    if curr_token.type != "CREDITS"
      raise ParseError, "How many of what?"
    end
    curr_token = get_next_token
    if curr_token.type != "IS"
      raise ParseError, "How many Credits do what?"
    end

    # Insert HOWMANY & GALNUMBER nodes into AST
    curr_node = Node.new("HOWMANY", nil, [], true, false)
    @output.insert(curr_node)
    curr_node = Node.new("GALNUMBER", nil, [], false, false)
    @output.insert(curr_node, @output.seek({:name => "HOWMANY"}))
    
    # Validate the rest of the sentence
    prev_token = nil
    curr_token = get_next_token(true, false)
    while curr_token.type != "QUESTION"
      if curr_token.type != "VARIABLE"
        raise ParseError, "I don't know what " + curr_token.value + " is!"
      end
      prev_token = curr_token
      curr_token = get_next_token(true, false)
      if curr_token.type == "QUESTION"
        prev_token.type = "COMMODITY"
        curr_node = Node.new("COMMODITY", prev_token.value, [], false, true)
        @output.insert(curr_node, @output.seek({:name => "HOWMANY"}))
      else
        prev_token.type = "GALNUM"
        curr_node = Node.new("GALNUMERAL", prev_token.value, [], false, true)
        @output.insert(curr_node, @output.seek({:name => "GALNUMBER"}))
      end
      @tokens.push(prev_token)
    end

    # Add "?" to @tokens
    @tokens.push(curr_token)
    
    handle_end
  end

  # This method parses the statement "How much is [ numeral ] ?".
  def how_much
    # Make sure statement begins with "How much is"
    if get_next_token.type != "IS"
      raise ParseError, "I don't know what you're talking about!"
    end

    # Add HOWMUCH & GALNUMBER nodes to @output
    curr_node = Node.new("HOWMUCH", nil, [], true, false)
    @output.insert(curr_node)
    curr_node = Node.new("GALNUMBER", nil, [], false, false)
    @output.insert(curr_node, @output.seek({:name => "HOWMUCH"}))

    # Make sure the rest of the statement is one or more Galactic Numerals
    curr_token = get_next_token(true, false)
    while curr_token.type != "QUESTION"
      if curr_token.type == "VARIABLE"
        curr_token.type = "GALNUM"
        curr_node = Node.new("GALNUMERAL", curr_token.value, [], false, true)
        @output.insert(curr_node, @output.seek({:name => "GALNUMBER"}))
      else
        raise ParseError, "I don't know what " + curr_token.value + " is!"
      end
      @tokens.push(curr_token)
      curr_token = get_next_token(true, false)
    end

    # Add "?" to @tokens
    @tokens.push(curr_token)

    handle_end
  end

  # This method handles assignment statements.
  def assign(curr_token = nil)
    # First handle errors
    if curr_token == nil
      raise ParseError, "I don't know what you're talking about!"
    elsif curr_token.type != "VARIABLE"
      raise ParseError, "I don't know what " + curr_token.value + " is!"
    end

    # Add ASSIGN node to @output
    curr_node = Node.new("ASSIGN", nil, [], true, false)
    @output.insert(curr_node)

    # The first variable in an assignment statement should always be
    # a Galactic Numeral, so we can declare it here.
    curr_token.type = "GALNUM"
    @tokens.push(curr_token)
    curr_node = Node.new("GALNUMERAL", curr_token.value, [], false, true)

    # Use assign_variable if only one variable is present
    # Use assign_value if otherwise
    curr_token = get_next_token(true, false)
    if curr_token.type == "IS"
      # Insert curr_node here so we don't have to pass it to assign_variable()
      @output.insert(curr_node, @output.seek({:name => "ASSIGN"}))
      assign_variable(curr_token)
    elsif curr_token.type == "VARIABLE"
      # Create GALNUMBER Node to contain all GALNUMERAL nodes & insert both it
      # and the first GALNUMERAL node into @output
      prev_node = curr_node
      curr_node = Node.new("GALNUMBER", nil, [], false, false)
      @output.insert(curr_node, @output.seek({:name => "ASSIGN"}))
      @output.insert(prev_node, @output.seek({:name => "GALNUMBER"}))
      assign_value(curr_token)
    else
      raise ParseError, "I don't know what you're talking about!"
    end
  end

  # This method parses the statement "variable is defined_numeral".
  # - curr_token: a Token object representing the current token
  def assign_variable(curr_token = nil)
    # First handle errors
    if curr_token == nil
      raise ParseError, "I need a variable!"
    end

    # Add "IS" to @tokens
    @tokens.push(curr_token)
    
    curr_token = get_next_token(true, false)
    if curr_token.type == "VARIABLE"
      curr_token.type = "GALNUM"
      @tokens.push(curr_token)
      curr_node = Node.new("GALNUMERAL", curr_token.value, [], false, true)
      @output.insert(curr_node, @output.seek({:name => "ASSIGN"}))
    else
      raise ParseError, "I don't know what " + curr_token.value + " is!"
    end

    handle_end
  end

  # This method parses the statement "{ defined_numeral }+ commodity IS number" 
  # - curr_token: a Token object representing the current token
  def assign_value(curr_token = nil)
    # First handler errors.
    if curr_token.type != "VARIABLE"
      raise ParseError, "I need a variable!"
    end
   
    # Validate up until the "IS" token
    while curr_token.type != "IS"
      prev_token = curr_token
      curr_token = get_next_token(true, false)
      if curr_token.type == "VARIABLE"
        prev_token.type = "GALNUM"
        curr_node = Node.new("GALNUMERAL", prev_token.value, [], false, true)
        @output.insert(curr_node, @output.seek({:name => "GALNUMBER"}))
      elsif curr_token.type == "IS"
        prev_token.type = "COMMODITY"
        curr_node = Node.new("COMMODITY", prev_token.value, [], false, true)
        @output.insert(curr_node, @output.seek({:name => "ASSIGN"}))
      else
        raise ParseError, "I don't know what " + curr_token.value + " is!"
      end
      @tokens.push(prev_token)
    end

    # Add "IS" to @tokens
    @tokens.push(curr_token)

    curr_token = get_next_token
    if curr_token.type != "NUMBER"
      raise ParseError, "I don't know what you're talking about!"
    else
      curr_node = Node.new("NUMBER", curr_token.value, [], false, true)
      @output.insert(curr_node, @output.seek({:name => "ASSIGN"}))
    end

    if get_next_token.type != "CREDITS"
      raise ParseError, "I don't know what you're talking about!"
    end

    handle_end
  end

  # This method handles the end of an input statement
  def handle_end
    if get_next_token(true, false).type != "NoTokenFound"
      raise ParseError, "I don't know what you're talking about!"
    #else
    #  puts @tokens.to_s
    end
  end

  # This is a convenience method to getting the next token from @lexer.
  # - ignore_whitespace: whether or not to skip over whitespace tokens
  # - auto_add: whether or not to automatically add token to @tokens
  def get_next_token(ignore_whitespace = true, auto_add = true)
    if ignore_whitespace
      token = @lexer.next_token(@input, @pos)
    else
      token = @lexer.next_token(@input, @pos, false)
    end
    #if token == nil
    #  return token
    #end
    if auto_add
      @tokens.push(token)
    end
    @pos = token.pos + token.value.length
    return token
  end
end

# [1] Since several statements accept a series of numerals followed by 
# a commodity variable it is not possible to determine whether a VARIABLE 
# returned by the lexical analyzer is really of type NUMERAL or COMMODITY
# without seeing if the next token starts the next part of the statement.

