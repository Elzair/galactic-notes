
# Class representing a lexical token
class Token
  # Create a new Token
  def initialize(type = "", value = "", pos = -1)
    @type = type
    @value = value
    @pos = pos
  end

  def to_s
    return @type.tos_s + " " + @value.to_s + " " + @pos.tos_s
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
    #@regexps = []
    if @rules.respond_to?(:has_key?)
      patterns = [] 
      #@regexp = Regexp.new(pattern)
      @rules.keys.each do |rule|
        #@regexps.push(Regexp.new(rule))
        pattern = "(?<" + @rules[rule] + ">" + rule + ")"
        patterns.push(pattern)
      end
      @regexp = Regexp.new(patterns.join("|"))
    else
      raise LexerError, "Input rules must be inside a hash!"
    end
  end

  def tokenize(input = "")
    print @regexp.match(input)
  end 
end
