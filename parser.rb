require './lexer.rb'

class ParseError < RuntimeError
end

# This is an LL(1) Recursive Descent Parser for the
# Galactic Notes program. It can be invoked with the
# Galactic Input grammar or the Roman Numeral Grammar 
class GalacticParser
  # Create new parser object
  def initialize(vm = nil, ignore_case = false)
    @vm = vm
    @ignore_case = ignore_case
    @history = []
    if @ignore_case
      @rules = {
        "HOW" => "HOW",
        "MANY" => "MANY",
        "MUCH" => "MUCH",
        "IS" => "IS",
        "QUIT" => "QUIT",
        "CREDITS" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    else
      @rules = {
        "How" => "HOW",
        "many" => "MANY",
        "much" => "MUCH",
        "is" => "IS",
        "quit" => "QUIT",
        "Credits" => "CREDITS",
        "[[:alpha:]]+" => "VARIABLE",
        "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
        "\\?" => "QUESTION",
        "\\s" => "WS",
        "\n" => "EOL"
      }
    end
    @lexer = Lexer.new(@rules, false)
  end

  # This method parses and handles input from the user
  def parse_input(input = "")
    if @ignore_case
      input = input.upcase
    end
    @output = []
    @history.push(input)
    @input = input
    @tokens = []
    @pos = 0
    statement
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

  # This method parses a call to quit the program.
  def quit
    handle_end
  end

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
      else
        prev_token.type = "GALNUM"
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

    # Make sure the rest of the statement is one or more Galactic Numerals
    curr_token = get_next_token(true, false)
    while curr_token.type != "QUESTION"
      if curr_token.type == "VARIABLE"
        curr_token.type = "GALNUM"
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

    # The first variable in an assignment statement should always be
    # a Galactic Numeral, so we can declare it here.
    curr_token.type = "GALNUM"
    @tokens.push(curr_token)

    # Use assign_variable if only one variable is present
    # Use assign_value if otherwise
    curr_token = get_next_token(true, false)
    if curr_token.type == "IS"
      assign_variable(curr_token)
    elsif curr_token.type == "VARIABLE"
      assign_value(curr_token)
    else
      raise ParseError, "I don't know what you're talking about!"
    end
  end

  # This method parses the statement "variable is defined_numeral".
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
    else
      raise ParseError, "I don't know what " + curr_token.value + " is!"
    end

    handle_end
  end

  def assign_value(curr_token = nil)
    # This method parses the statement "{ defined_numeral }+ commodity IS number" 

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
      elsif curr_token.type == "IS"
        prev_token.type = "COMMODITY"
      else
        raise ParseError, "I don't know what " + curr_token.value + " is!"
      end
      @tokens.push(prev_token)
    end

    # Add "IS" to @tokens
    @tokens.push(curr_token)

    if get_next_token.type != "NUMBER"
      raise ParseError, "I don't know what you're talking about!"
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
    else
      puts @tokens.to_s
    end
  end

  # This is a convenience method to getting the next token from @lexer.
  def get_next_token(ignore_whitespace = true, auto_add = true)
    if ignore_whitespace
      token = @lexer.next_token(@input, @pos)
    else
      token = @lexer.next_token(@input, @pos, false)
    end
    if token == nil
      return token
    end
    if auto_add
      @tokens.push(token)
    end
    @pos = token.pos + token.value.length
    return token
  end
end

