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
    token = get_next_token(false)

    # Use token to determine which rule to use.
    if token.type == "HOWMANY"
      how_many
    elsif token.type == "HOWMUCH"
      how_much
    elsif token.type == "QUIT"
      quit
    elsif token.type == "VARIABLE"
      assign
    else
      raise ParseError, "Invalid input: " + input
    end
  end

  def quit
    return ""
  end

  def how_many
    # Get next token.
    token = get_next_token

    if token.type != "CREDITS"
      raise ParseError, "How many of what?"
    end

    # Get next token.
    token = get_next_token

    # Validate that current token has type "IS"
    if token.type != "IS"
      raise ParseError, 'How many Credits do what?'
    end

    # Validate number 
    token = galactic_number

    # Validate commodity
    commodity(token, true)

    # Verify final token is question mark
    token = get_next_token(true, true)
    if token.type != "QUESTION"
      raise ParseError, "Are you asking me or telling me?"
    end

    if get_next_token != nil
      raise ParseError, "I don't know what you're talking about!"
    end
  end

  def assign
    # Validate number
    
  end

  def galactic_number(validate = true)
    loop do
      token = get_next_token(true, false)
      if token.type == "VARIABLE"
        if validate == true
          @vm.load_type("NUMERAL").each do |tok|
            if tok.name == token.value and !tok.base
              token.type = "GALACTIC"
              @tokens.push(token)
              break
            end
          end
          return token
        else
          @tokens.push(token)
        end
      else
        break
      end
    end
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
  end

  def commodity(token = nil, validate = true)
    if token == nil
      token = get_next_token(true, false)
    end
    if validate == true
      @vm.load_type("COMMODITY").each do |tok|
        if tok.name == token.value and !tok.base
          @tokens.push(token)
        end
      end
      raise ParseError, "This Commodity does not exist!"
    end
  end

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

