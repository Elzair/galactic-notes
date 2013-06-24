require './lexer.rb'

# This is an LL(1) Recursive Descent Parser for the
# Galactic Notes program. It can be invoked with the
# Galactic Input grammar or the Roman Numeral Grammar 
class Parser
  # Create new parser object
  def initialize(input = "")
    @history = []
    @rules = {
      "How\\smany" => "HOWMANY",
      "How\\smuch" => "HOWMUCH",
      "is" => "IS",
      "[[:alpha:]]+" => "VARIABLE",
      "[0-9]+\\.[0-9]+|[0-9]+" => "NUMBER",
      "\\?" => "QUESTION",
      "\\s" => "WS",
      "\n" => "EOL",
    }
    @lexer = Lexer.new(@rules, false)
  end

  def get_input(input = "")
    @history.push(input)
    @lexer.tokenize(input)
  end

  def set(tok = "")
    if !@tokens.keys.include?(tok)
      @tokens[tok] = Token.new(tok)
    end
  end

  def get(tok = nil)
    if tok != nil
      return @tokens[tok]
    end
  end

  def get_all
    return @tokens.values.to_s
  end
end

