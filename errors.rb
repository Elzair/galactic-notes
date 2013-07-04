
# This class represents an error encountered by the Abstract Syntax Tree
# during its operations.
class ASTreeError < RuntimeError
end

# This class represents an error encountered by the Lexical Analyzer
# during its operations.
class LexerError < RuntimeError
end

# This class represents an error encountered by the Main Object 
# during its operations.
class MainError < RuntimeError
end

# This class represents an error encountered by the Parser 
# during its operations.
class ParserError < RuntimeError
end

# This class represents an error encountered by the Translator 
# during its operations.
class TranslatorError < RuntimeError
end

# This class represents an error encountered by the Virtual Machine
# during its operations.
class VMError < RuntimeError
end
