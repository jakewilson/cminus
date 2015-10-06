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
        case @token.type
            when TokenType::SEMICOLON
                match(TokenType::SEMICOLON)

            when TokenType::LEFT_PAREN
                match(TokenType::LEFT_PAREN)
                params
                match(TokenType::RIGHT_PAREN)
                compound_stmt
                
            when TokenType::LEFT_BRACKET
                
            else
                raise Reject
        end
    end

    def var_dec
        type_spec_id
        if @token.type == TokenType::SEMICOLON
            match(TokenType::SEMICOLON)
        else
            match(TokenType::LEFT_BRACKET)
            match(TokenType::NUM)
            match(TokenType::RIGHT_BRACKET)
            match(TokenType::SEMICOLON)
        end
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

    def func_dec
        type_spec_id
        match(TokenType::LEFT_PAREN)
        params
        match(TokenType::RIGHT_PAREN)
        compound_stmt
    end

    def type_spec_id
        type_spec
        match(TokenType::ID)
    end


    def params
        if @token.type == TokenType::VOID
            match(TokenType::VOID)
        else
            param_list
        end
    end

    def param_list
        param
        while (@token.type == TokenType::COMMA)
            match(TokenType::COMMA)
            param
        end
    end

    def param
        type_spec_id
        if (@token.type == TokenType::LEFT_BRACKET)
            match(TokenType::LEFT_BRACKET)
            match(TokenType::RIGHT_BRACKET)
        end
    end

    def compound_stmt
        # TODO may need to change
        match(TokenType::LEFT_BRACE)
        local_dec
        #stmt_list
        match(TokenType::RIGHT_BRACE)
    end

    def local_dec
        while $first["local_dec"].index(@token.type)
            var_dec
        end
    end

    def stmt_list
        while $first["stmt"].index(@token.type)
            stmt
        end
    end

    def stmt

    end

    def exp_stmt
        if @token.type == TokenType::SEMICOLON
            match(TokenType::SEMICOLON)
        else
            # TODO
            #exp
            match(TokenType::SEMICOLON)
        end
    end

    def select_stmt
        match(TokenType::IF)
        match(TokenType::LEFT_PAREN)
        #exp
        match(TokenType::RIGHT_PAREN)
        if @token.type == TokenType::ELSE
            match(TokenType::ELSE)
            stmt
        end
    end

    def iter_stmt

    end

    def return_stmt
        
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
