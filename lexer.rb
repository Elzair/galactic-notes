
# Class representing a lexical token
class Token
  # Create a new Token
  def initialize(type = "", value = "", pos = -1)
    @type = type
    @value = value
    @pos = pos
  end

  def to_s
    return @type + " " + @value.to_s + " " + @pos.to_s
  end
end

# This class represents an exception raised by Lexer
class LexerError < RuntimeError
end

# This class analyzes an input string and separates it
# into tokens defined by the inputted series of rules.
class Lexer
  def initialize(rules, skip_whitespace = true)
    @rules = rules
    @skip_whitespace = skip_whitespace
    @regexps = {}
    if @rules.respond_to?(:has_key?)
      # Create a regular expression for each individual rule. 
      @rules.keys.each do |rule|
        @regexps[@rules[rule]] = Regexp.new(rule)
      end
    else
      raise LexerError, "Input rules must be inside a hash!"
    end
  end

  # This method splits up the input string into a list of
  # token objects according to the inputted rules.
  def tokenize(input = "")
    pos = 0
    tokens = []
    # Process the input string into tokens.
    until pos == input.length
      # Match the current position of the input string
      # against all rules to find the best match
      @regexps.keys.each do |reg|
        if input.index(@regexps[reg], pos) == pos
          token = @regexps[reg].match(input, pos)
          tokens.push(Token.new(reg, token, pos))
          pos = pos + token.to_s.length
        end
      end 
    end
    return tokens
  end 
end
