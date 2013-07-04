
# This class analyzes an input string and separates it
# into tokens defined by the inputted series of rules.
class Lexer
  # This method creates a new Lexer object.
  # - token_class: the class name of a lexical token
  # - err_class: the class name of the error to raise
  # - rules: a hash providing rules to match tokens in the language
  def initialize(token_class, err_class, rules = {})
    @token_class = token_class
    @err_class = err_class
    @rules = rules
    @regexps = {}
    if @rules.respond_to?(:has_key?)
      # Create a regular expression for each individual rule. 
      @rules.keys.each do |rule|
        if rule == "NoTokenFound"
          raise @err_class, "You cannot define a grammar rule called 'NoTokenFound'!"
        end
        @regexps[@rules[rule]] = Regexp.new(rule)
      end
    else
      raise @err_class, "Input rules must be inside a hash!"
    end
  end

  # This method takes an input String and returns an Array of tokens
  # matching the expressions in @rules.
  # - input: the input String
  # - ignore_whitespace: whether or not to skip whitespace tokens
  # returns: an Array of Token objects
  def tokenize(input = "", ignore_whitespace = true)
    # Ensure input is a nonempty string
    if input == nil or input == ""
      raise @err_class, "You must enter something!"
    end
    
    # Initialize needed variables
    tokens = [] # Array containing all the tokens from input
    pos = 0

    # Tokenize entire input string
    begin
      curr_token = next_token(input, pos, ignore_whitespace)
      if curr_token.type == "NoTokenFound"
        raise @err_class, "Invalid Token: #{curr_token.value.to_s}"
      else
        tokens.push(curr_token)
        pos = curr_token.pos + curr_token.value.length 
      end
    end while curr_token.type != "EOL"

    return tokens
  end

  # This method returns the next substring of input
  # that matches one of the inputted rules
  # - input: a String analyzed for the next token
  # - pos: a FixNum representing the position in input to began matching
  # - ignore_whitespace: whether or not to skip over whitespace tokens
  def next_token(input = "", pos = 0, ignore_whitespace = true)
    # First check if parser has reached the end of the string
    # or if pos simply has an invalid value (i.e. -1)
    if pos < 0
      pos = 0
      return @token_class.new("NoTokenFound", input[pos...-1], pos)
    end
    if pos >= input.length
      return @token_class.new("EOL", "", pos)
    end

    # Match the current position of the input string
    # against all rules to find the best match
    token = nil
    @regexps.keys.each do |reg|
      if input.index(@regexps[reg], pos) == pos
        token = @token_class.new(reg, @regexps[reg].match(input, pos).to_s, pos)
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
      token = @token_class.new("NoTokenFound", input[pos...-1], pos) 
    end
  end
end
