# Class representing a lexical token
class Token
  attr_accessor :type
  attr_accessor :value
  attr_accessor :pos

  # This method creates a new Token object.
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
  # This method creates a new Lexer object
  # - rules: a hash providing rules to match tokens in the language
  def initialize(rules)
    @rules = rules
    @regexps = {}
    if @rules.respond_to?(:has_key?)
      # Create a regular expression for each individual rule. 
      @rules.keys.each do |rule|
        if rule == "NoTokenFound"
          raise LexerError, "You cannot define a grammar rule called 'NoTokenFound'!"
        end
        @regexps[@rules[rule]] = Regexp.new(rule)
      end
    else
      raise LexerError, "Input rules must be inside a hash!"
    end
  end

  # This method returns the next substring of input
  # that matches one of the inputted rules
  # - input: a String analyzed for the next token
  # - pos: a FixNum representing the position in input to began matching
  # - ignore_whitespace: whether or not to skip over whitespace tokens
  def next_token(input = "", pos = 0, ignore_whitespace = true)
    # First check if parser has reached the end of the string
    if pos >= input.length
      return Token.new("NoTokenFound", input[pos...-1], pos)
    end

    # Match the current position of the input string
    # against all rules to find the best match
    token = nil
    @regexps.keys.each do |reg|
      if input.index(@regexps[reg], pos) == pos
        token = Token.new(reg, @regexps[reg].match(input, pos).to_s, pos)
        # If ignore_whitespace is true, return next non-whitespace token
        if token.value.gsub(/\s+/, "") == ""
          return next_token(input, pos + token.value.length, true)
        else
          return token
        end
      end
    end 

    # Return Error token if no other tokens were found
    if token == nil
      token = Token.new("NoTokenFound", input[pos...-1], pos) 
      #raise LexerError, "Invalid token(s): " + input[pos..-1]
    end
  end
end
