# Class representing a lexical token
class Token
  # Create a new Token
  def initialize(type = "", value = "", pos = -1)
    @type = type
    @value = value
    @pos = pos
  end

  def type
    return @type
  end

  def value
    return @value
  end

  def pos
    return @pos
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
      old_pos = pos
      @regexps.keys.each do |reg|
        if input.index(@regexps[reg], pos) == pos
          token = @regexps[reg].match(input, pos)
          tokens.push(Token.new(reg, token, pos))
          pos = pos + token.to_s.length
          break
        end
      end 
      # Raise error if no tokens were found
      if pos == old_pos
        raise LexerError, "Invalid token(s): " + input[pos..-1]
      end
    end
    return tokens
  end 

  # This method returns the next substring of input
  # that matches one of the inputted rules
  def next_token(input = "", pos = 0)
    if pos >= input.length
      return nil
    end
    # Match the current position of the input string
    # against all rules to find the best match
    token = nil
    @regexps.keys.each do |reg|
      if input.index(@regexps[reg], pos) == pos
        token = Token.new(reg, @regexps[reg].match(input, pos), pos)
        return token
        #drint token.to_s
        #break # end loop if regexp matched
      end
    end 
    # Raise error if no tokens were found
    if token == nil 
      raise LexerError, "Invalid token(s): " + input[pos..-1]
    #else
      #return token
    end
  end

  # This method returns the next non-whitespace token
  def next_token_no_ws(input = "", pos = 0)
    token = next_token(input, pos)
    pos = token.pos + token.value.length
    if token.type != "WS"
      return token
    else
      return next_token_no_ws(input, pos)
    end
  end
end
