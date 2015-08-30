# scanner.rb
#
# Author: Jake Wilson
# Date: 08/29/15
#

require_relative 'types.rb'

class Scanner

    def self.getTokenType(input)
        state = State::START
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
            puts id
            return TokenType::ID
        
        elsif char =~ /[0-9]/ # is digit
            num = char
            while (char = input.getc) =~ /[0-9]/
                num += char
            end

            # make sure not to consume the next character
            input.seek(-1, IO::SEEK_CUR)
            puts num
            return TokenType::NUM

        else # special symbols
            ret = ""
            case char
                when '+'
                    ret = TokenType::PLUS
                when '-'
                    ret = TokenType::MINUS
                when '*'
                    
                    # TODO */
                when '/'
                    # TODO // and /*
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
                    end
                when ';'
                    ret = TokenType::SEMICOLON
                when ','
                    ret = TokenType::COMMA
                when '['
                    ret = TokenType::LEFT_BRACKET
                when ']'
                    ret = TokenType::RIGHT_BRACKET
                when '{'
                    ret = TokenType::LEFT_BRACE
                when '}'
                    ret = TokenType::RIGHT_BRACE
                when '('
                    ret = TokenType::LEFT_PAREN
                    puts char
                when ')'
                    ret = TokenType::RIGHT_PAREN
                    puts char
                else
                    return TokenType::EOF
            end
        end

    end # end def

end
