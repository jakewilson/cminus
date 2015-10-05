# scanner.rb
#
# Author: Jake Wilson
# Date: 08/29/15
#

require './types.rb'

class Scanner

    def self.chr(c)
        if c != nil
            return c.chr
        end
        return nil
    end

    ##
    # Prints the input line if the debug flag is on
    ##
    def self.printLine(input)
        if !$debug
            return
        end
        input.lineno += 1
        if entire_file[input.lineno] != nil
            puts "\nINPUT: " + entire_file[input.lineno]
        end
    end

    ##
    # Prints the token without a newline
    ##
    def self.printToken(token)
        if !$debug
            return
        end
        print token
    end

    ##
    # Prints the token with a newline
    ##
    def self.putToken(token)
        if !$debug
            return
        end
        puts token
    end

    def self.getToken(input)
        done = true
        ret  = nil
        loop do
            done = true
            char = chr(input.getc)

            # eat up all whitespace before anything else
            if char =~ /\s/
                if char == "\n"
                    printLine(input)
                end
                while (char = chr(input.getc)) =~ /\s/
                    if char == "\n"
                        printLine(input)
                    end
                end
            end

            if char =~ /[a-z]/i # is letter
                id = char
                while (char = chr(input.getc)) =~ /[a-z]/i
                    id += char
                end
    
                # make sure not to consume the next character
                input.seek(-1, IO::SEEK_CUR)
                if is_keyword(id)
                    # see types.rb
                    ret = Token.new($keywords.index(id) + 2, id)
                    printToken "keyword: "
                else 
                    ret = Token.new(TokenType::ID, id)
                    printToken "ID: "
                end
                putToken id

            elsif char =~ /[0-9]/ # is digit
                num = char
                while (char = chr(input.getc)) =~ /[0-9]/
                    num += char
                end

                float = ''
                if char == '.'
                    float = num
                    float += '.'
                    if (char = chr(input.getc)) =~ /[0-9]/
                        float += char
                        while (char = chr(input.getc)) =~ /[0-9]/
                            float += char
                        end
                    else
                        putToken "error: " + float
                        input.seek(-1, IO::SEEK_CUR)
                        return Token.new(TokenType::ERROR, "ERROR")
                    end
                end

                if char == 'E'
                    if float != ''
                        float += 'E'
                    else
                        float = num + 'E'
                    end

                    char = chr(input.getc)
                    if char == '+' || char == '-'
                        float += char
                        char = chr(input.getc)
                    end

                    if char =~ /[0-9]/
                        float += char
                        while (char = chr(input.getc)) =~ /[0-9]/
                            float += char
                        end
                    else
                        putToken "error: " + float
                        input.seek(-1, IO::SEEK_CUR)
                        return Token.new(TokenType::ERROR, "ERROR")
                    end
                end

                # make sure not to consume the next character
                input.seek(-1, IO::SEEK_CUR)
                if float != ''
                    putToken "FLOAT: " + float
                    ret = Token.new(TokenType::FLOAT_NUM, float)
                else
                    putToken "NUM: " + num
                    ret = Token.new(TokenType::NUM, num)
                end

            else # special symbols
                case char
                    when '+'
                        ret = Token.new(TokenType::PLUS, char)
                        putToken '+'

                    when '-'
                        ret = Token.new(TokenType::MINUS, char)
                        putToken '-'

                    when '*'
                        ret = Token.new(TokenType::TIMES, char)
                        putToken '*'

                    when '/'
                        comment = 0
                        char = chr(input.getc)
                        if char == '*' # block comment
                            comment += 1
                            while comment > 0
                                char = chr(input.getc)
                                if char == '*'
                                    if chr(input.getc) == '/'
                                        comment -= 1
                                    else
                                        input.seek(-1, IO::SEEK_CUR)
                                    end
                                elsif char == '/'
                                    if chr(input.getc) == '*'
                                        comment += 1
                                    else
                                        input.seek(-1, IO::SEEK_CUR)
                                    end
                                elsif char == "\n"
                                    printLine(input)
                                end
                            end
                            done = false
                        elsif char == '/' # line comment
                            while (char = chr(input.getc)) != "\n"
                            end
                            done = false
                        else
                            ret = Token.new(TokenType::DIVIDE, '/')
                            input.seek(-1, IO::SEEK_CUR)
                            putToken '/'
                        end

                    when '<'
                        if chr(input.getc) == '='
                            ret = Token.new(TokenType::LTE, "<=")
                            putToken '<='
                        else
                            ret = Token.new(TokenType::LT, char)
                            putToken '<'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '>'
                        if chr(input.getc) == '='
                            ret = Token.new(TokenType::GTE, ">=")
                            putToken '>='
                        else
                            ret = Token.new(TokenType::GT, char)
                            putToken '>'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '='
                        if chr(input.getc) == '='
                            ret = Token.new(TokenType::IS_EQUAL, "==")
                            putToken '=='
                        else
                            ret = Token.new(TokenType::ASSIGN, char)
                            putToken '='
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '!'
                        if chr(input.getc) == '='
                            ret = Token.new(TokenType::NOT_EQUAL, char)
                            putToken '!='
                        else
                            ret = Token.new(TokenType::ERROR, char)
                            putToken "ERROR: !"
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when ';'
                        ret = Token.new(TokenType::SEMICOLON, char)
                        putToken ';'

                    when ','
                        ret = Token.new(TokenType::COMMA, char)
                        putToken ','

                    when '['
                        ret = Token.new(TokenType::LEFT_BRACKET, char)
                        putToken '['

                    when ']'
                        ret = Token.new(TokenType::RIGHT_BRACKET, char)
                        putToken ']'

                    when '{'
                        ret = Token.new(TokenType::LEFT_BRACE, char)
                        putToken '{'

                    when '}'
                        ret = Token.new(TokenType::RIGHT_BRACE, char)
                        putToken '}'

                    when '('
                        ret = Token.new(TokenType::LEFT_PAREN, char)
                        putToken char

                    when ')'
                        ret = Token.new(TokenType::RIGHT_PAREN, char)
                        putToken char

                    when nil
                        ret = Token.new(TokenType::EOF, "EOF")

                    else # invalid char
                        putToken "error: " + char.to_s
                        ret = Token.new(TokenType::ERROR, "ERROR")
                end
            end # special symbols
            break if done == true
        end
        if ret == nil
            puts "ret is nil"
            return Token.new(TokenType::ERROR, "ERROR")
        end
        return ret
    end # end def

    def self.is_keyword(id)
        case id
        when "else", "if", "int", "void", "return", "while", "float"
            return true
        end
        return false
    end

    def initialize
        @entire_file = []
    end

    def self.entire_file
        @entire_file
    end

    def self.entire_file=file
        @entire_file = file
    end
end
