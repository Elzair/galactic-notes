require './lexer.rb'

class Parser
  # Create new object
  def initialize(tokens = {})
    @tokens = tokens
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

