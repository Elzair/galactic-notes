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

  def parse_input(input = "")
    @history.push(input)
    result = @lexer.tokenize(input)
    result.each do |token|
      puts token.to_s
    end
  end
end

