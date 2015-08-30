# scanner.rb
#
# Author: Jake Wilson
# Date: 08/29/15
#

require_relative 'types.rb'

class Scanner

    def self.getTokenType(input)
        done = true
        ret  = TokenType::ERROR
        loop do
            done = true
            char = input.getc

            # eat up all whitespace before anything else
            if char =~ /\s/
                while (char = input.getc) =~ /\s/
                end
            end

            if char =~ /[a-z]/i # is letter
                id = char
                while (char = input.getc) =~ /[a-z]/i
                    id += char
                end
    
                # make sure not to consume the next character
                input.seek(-1, IO::SEEK_CUR)
                ret = TokenType::ID
                if is_keyword(id)
                    ret = TokenType::KEYWORD
                    print "keyword: "
                end
                puts id

            elsif char =~ /[0-9]/ # is digit
                num = char
                while (char = input.getc) =~ /[0-9]/
                    num += char
                end

                # make sure not to consume the next character
                input.seek(-1, IO::SEEK_CUR)
                puts num
                ret = TokenType::NUM

            else # special symbols
                case char
                    when '+'
                        ret = TokenType::PLUS
                        puts '+'

                    when '-'
                        ret = TokenType::MINUS
                        puts '-'

                    when '*'
                        ret = TokenType::TIMES
                        puts '*'

                    when '/'
                        comment = 0
                        char = input.getc
                        if char == '*' # block comment
                            comment += 1
                            while comment > 0
                                char = input.getc
                                if char == '*'
                                    if input.getc == '/'
                                        comment -= 1
                                    else
                                        input.seek(-1, IO::SEEK_CUR)
                                    end
                                elsif char == '/'
                                    if input.getc == '*'
                                        comment += 1
                                    else
                                        input.seek(-1, IO::SEEK_CUR)
                                    end
                                end
                            end
                            done = false
                        elsif char == '/' # line comment
                            while (char = input.getc) != "\n"
                            end
                            done = false
                        else
                            ret = TokenType::DIVIDE
                            input.seek(-1, IO::SEEK_CUR)
                            puts '/'
                        end

                    when '<'
                        ret = TokenType::LT
                        if input.getc == '='
                            ret = TokenType::LTE
                            puts '<='
                        else
                            puts '<'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '>'
                        ret = TokenType::GT
                        if input.getc == '='
                            ret = TokenType::GTE
                            puts '>='
                        else
                            puts '>'
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '='
                        ret = TokenType::ASSIGN
                        if input.getc == '='
                            ret = TokenType::IS_EQUAL
                            puts '=='
                        else
                            puts '='
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when '!'
                        if input.getc == '='
                            ret = TokenType::NOT_EQUAL
                            puts '!='
                        else
                            ret = TokenType::ERROR
                            input.seek(-1, IO::SEEK_CUR)
                        end

                    when ';'
                        ret = TokenType::SEMICOLON
                        puts ';'

                    when ','
                        ret = TokenType::COMMA
                        puts ','

                    when '['
                        ret = TokenType::LEFT_BRACKET
                        puts '['

                    when ']'
                        ret = TokenType::RIGHT_BRACKET
                        puts ']'

                    when '{'
                        ret = TokenType::LEFT_BRACE
                        puts '{'

                    when '}'
                        ret = TokenType::RIGHT_BRACE
                        puts '}'

                    when '('
                        ret = TokenType::LEFT_PAREN
                        puts char

                    when ')'
                        ret = TokenType::RIGHT_PAREN
                        puts char

                    when nil
                        ret = TokenType::EOF

                    else # invalid char
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

end
