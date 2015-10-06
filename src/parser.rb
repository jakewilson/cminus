##
# parser.rb
# Author: Jake Wilson
# Date: 10/4/15
##

class Parser
    def initialize(input)
        @input = input
        @token = Scanner.getToken(input)
    end

    def parse
        prog
        # TODO check for EOF
    end

    def prog
        dec_list
    end

    def dec_list
        dec
        # TODO while loop
    end

    def dec
        type_spec_id
    end

    def type_spec_id
        type_spec
        match(TokenType::ID)
    end

    def type_spec
        case @token.val
            when 'int'
                match(TokenType::INT)
            when 'float'
                match(TokenType::FLOAT)
            when 'void'
                match(TokenType::VOID)
            else
                raise Reject
        end
    end

    ##
    # Matches the current token type with the expected token type
    ##
    def match(expected)
        if (@token.type == expected)
            @token = Scanner.getToken(@input)
        else
            raise Reject
        end
    end
end
