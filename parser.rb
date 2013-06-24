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
    @history.push(input)
    tokens = []
    pos = 0
    #result = @lexer.tokenize(input)
    #result.each do |token|
    #  puts token.to_s
    #end
    statement(input, tokens, pos)
  end

  # This function matches the top level rule for
  # the Galactic Notes input grammar.
  def statement(input = "", tokens = [], pos)
    # Get next token
    token = @lexer.next_token(input, pos)
    puts "RET" + token.to_s
    tokens.push(token)
    pos = token.pos + token.value.length

    # Use token to determine which rule to use.
    if token.type == "HOWMANY"
      how_many(input, tokens, pos)
    elsif token.type == "HOWMUCH"
      how_much(input, tokens, pos)
    elsif token.type == "VARIABLE"
      assign(input, tokens, pos)
    else
      raise ParseError, "Invalid input: " + input
    end
  end

  def how_many(input = "", tokens = [], pos = 0)
    # Get next token.
    token = @lexer.next_token_no_ws(input, pos)
    tokens.push(token)
    pos = token.pos + token.value.length
    
    # Validate that the current token is a valid currency.
    matched = false
    @vm.load_type("CURRENCY").each do |currency|
      if token.value == currency.name
        matched = true
        break
      end
    end
    if !matched
      raise ParseError, token.value + ' is an invalid currency!'
    end

    # Get next token.
    token = @lexer.next_token_no_ws(input, pos)
    tokens.push(token)
    pos = token.pos + token.value.length

    # Validate that current token has type "IS"
    if token.type != "IS"
      raise ParseError, 'How many do what?'
    end

    # Validate 
  end
end

