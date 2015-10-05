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

    def self.getTokenType(input)
        done = true
        ret  = TokenType::ERROR
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
                ret = TokenType::ID
                if is_keyword(id)
                    ret = TokenType::KEYWORD
                    printToken "keyword: "
                else 
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
                        return TokenType::ERROR
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
                        return TokenType::ERROR
                    end
                end

                # make sure not to consume the next character
                input.seek(-1, IO::SEEK_CUR)
                if float != ''
                    putToken "FLOAT: " + float
                    ret = TokenType::FLOAT
                else
                    putToken "NUM: " + num
                    ret = TokenType::NUM
                end

            else # special symbols
                case char
                    when '+'
                        ret = TokenType::PLUS
                        putToken '+'

                    when '-'
                        ret = TokenType::MINUS
                        putToken '-'

                    when '*'
                        ret = TokenType::TIMES
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
                            ret = TokenType::DIVIDE
                            input.seek(-1, IO::SEEK_CUR)
                            putToken '/'
                        end

                    when '<'
                        ret = TokenType::LT
                        if chr(input.getc) == '='
                            ret = TokenType::LTE
                            putToken '<='
                        else
                            putToken '<'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '>'
                        ret = TokenType::GT
                        if chr(input.getc) == '='
                            ret = TokenType::GTE
                            putToken '>='
                        else
                            putToken '>'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '='
                        ret = TokenType::ASSIGN
                        if chr(input.getc) == '='
                            ret = TokenType::IS_EQUAL
                            putToken '=='
                        else
                            putToken '='
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '!'
                        if chr(input.getc) == '='
                            ret = TokenType::NOT_EQUAL
                            putToken '!='
                        else
                            ret = TokenType::ERROR
                            putToken "ERROR: !"
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when ';'
                        ret = TokenType::SEMICOLON
                        putToken ';'

                    when ','
                        ret = TokenType::COMMA
                        putToken ','

                    when '['
                        ret = TokenType::LEFT_BRACKET
                        putToken '['

                    when ']'
                        ret = TokenType::RIGHT_BRACKET
                        putToken ']'

                    when '{'
                        ret = TokenType::LEFT_BRACE
                        putToken '{'

                    when '}'
                        ret = TokenType::RIGHT_BRACE
                        putToken '}'

                    when '('
                        ret = TokenType::LEFT_PAREN
                        putToken char

                    when ')'
                        ret = TokenType::RIGHT_PAREN
                        putToken char

                    when nil
                        ret = TokenType::EOF

                    else # invalid char
                        putToken "error: " + char.to_s
                        ret = TokenType::ERROR
                end
            end # special symbols
            break if done == true
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
