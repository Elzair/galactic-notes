require './lexer.rb'

class ParseError < RuntimeError
end

# This is an LL(1) Recursive Descent Parser for the
# Galactic Notes program. It can be invoked with the
# Galactic Input grammar or the Roman Numeral Grammar 
class GalacticParser
  # Create new parser object
  def initialize(vm = nil)
    @vm = vm
    @history = []
    @rules = {
      "How\\smany" => "HOWMANY",
      "How\\smuch" => "HOWMUCH",
      "is" => "IS",
      "quit" => "QUIT",
      "Credits" => "CREDITS",
      "[[:alpha:]]+" => "VARIABLE",
      "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
      "\\?" => "QUESTION",
      "\\s" => "WS",
      "\n" => "EOL"
    }
    @lexer = Lexer.new(@rules, false)
  end

  # This method parses and handles input from the user
  def parse_input(input = "")
    @output = []
    @history.push(input)
    @input = input
    @tokens = []
    @pos = 0
    #result = @lexer.tokenize(input)
    #result.each do |token|
    #  puts token.to_s
    #end
    statement
  end

  # This function matches the top level rule for
  # the Galactic Notes input grammar.
  def statement
    # Get next token
    #token = @lexer.next_token(input, @pos)
    #puts token.to_s
    #@tokens.push(token)
    #@pos = token.pos + token.value.length
    curr_token = get_next_token(false, false)

    # Use curr_token to determine which rule to use
    if curr_token.type == "HOWMANY"
      @tokens.push(curr_token)
      how_many
    elsif curr_token.type == "HOWMUCH"
      @tokens.push(curr_token)
      how_much
    elsif curr_token.type == "QUIT"
      @tokens.push(curr_token)
      quit
    elsif curr_token.type == "VARIABLE"
      assign(curr_token)
    else
      raise ParseError, "Invalid input: " + input
    end
  end

  def quit
    # This method handles a call to quit the program.
    handle_end
  end

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

    # Validate number 
    #token = galactic_number

    # Validate commodity
    #commodity(token, true)

    # Verify final token is question mark
    #token = get_next_token(true, true)
    #if token.type != "QUESTION"
    #  raise ParseError, "Are you asking me or telling me?"
    #end

    handle_end
  end

  def howmuch
    # This method parses the statement "How much is [ numeral ] ?".

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

  def assign(curr_token = nil)
    # This method handles assignment statements.

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

  def assign_variable(curr_token = nil)
    # This method parses the statement "variable is defined_numeral".

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

  def handle_end
    # This method handles the end of an input statement
    if get_next_token != nil
      raise ParseError, "I don't know what you're talking about!"
    else
      puts @tokens.to_s
    end
  end

  #def galactic_number(validate = true)
  #  loop do
  #    token = get_next_token(true, false)
  #    if token.type == "VARIABLE"
  #      if validate == true
  #        @vm.load_type("NUMERAL").each do |tok|
  #          if tok.name == token.value and !tok.base
  #            token.type = "GALACTIC"
  #            @tokens.push(token)
  #            break
  #          end
  #        end
  #        return token
  #      else
  #        @tokens.push(token)
  #      end
  #    else
  #      break
  #    end
  #  end
    # Use a different lexer to parse roman numerals
    #number = "" 
    #old_pos = @pos   
    #loop do
    #  token = get_next_token(true, false)
    #  if token.type == "NUMERAL" and !token.base
    #    @vm.get_type("NUMERAL").each do |tok|
    #      if tok.name == token.value and !tok.base 
    #        number = number + tok.value
    #        break
    #      end 
    #    end
    #    raise ParseError, token.name + " is not defined!"
    #  elsif number == "" 
    #    raise ParseError, "Galactic numerals needed!"
    #  else
    #    @tokens.push(Token.new("NUMBER", number, old_pos))
    #    break
    #  end
    #end
    #@tokens.push(Token.new()
  #end

 # def commodity(token = nil, validate = true)
 #   if token == nil
 #     token = get_next_token(true, false)
 #   end
 #   if validate == true
 #     @vm.load_type("COMMODITY").each do |tok|
 #       if tok.name == token.value and !tok.base
 #         @tokens.push(token)
 #       end
 #     end
 #     raise ParseError, "This Commodity does not exist!"
 #   end
 # end

  # This is a convenience method to getting the next
  # token from Lexer.
  def get_next_token(skip_whitespace = true, auto_add = true)
    if skip_whitespace
      token = @lexer.next_token_no_ws(@input, @pos)
    else
      token = @lexer.next_token(@input, @pos)
    end
    if token == nil
      return token
    end
    if auto_add
      @tokens.push(token)
    end
    @pos = token.pos + token.value.length
    #puts token
    return token
  end
end

