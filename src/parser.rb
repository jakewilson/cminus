##
# parser.rb
# Author: Jake Wilson
# Date: 10/4/15
##

class Parser
    def initialize(input)
        @input = input
        @token = Scanner.getToken(input)
        @prev_token = nil
        @next_token = nil
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
                # TODO                
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
        match(TokenType::LEFT_BRACE)
        local_dec
        stmt_list
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
        if $first["select-stmt"].index(@token.type)
            select_stmt
        elsif $first["compound-stmt"].index(@token.type)
            compound_stmt
        elsif $first["return-stmt"].index(@token.type)
            return_stmt
        elsif $first["iter-stmt"].index(@token.type)
            iter_stmt
        elsif $first["exp-stmt"].index(@token.type)
            exp_stmt
        else
            match(TokenType::ERROR)
        end
    end

    def exp_stmt
        if @token.type == TokenType::SEMICOLON
            match(TokenType::SEMICOLON)
        else
            exp
            match(TokenType::SEMICOLON)
        end
    end

    def select_stmt
        match(TokenType::IF)
        match(TokenType::LEFT_PAREN)
        exp
        match(TokenType::RIGHT_PAREN)
        stmt
        if @token.type == TokenType::ELSE
            match(TokenType::ELSE)
            stmt
        end
    end

    def iter_stmt
        match(TokenType::WHILE)
        match(TokenType::LEFT_PAREN)
        exp
        match(TokenType::RIGHT_PAREN)
        stmt
    end

    def return_stmt
        match(TokenType::RETURN)
        if @token.type == TokenType::SEMICOLON
            match(TokenType::SEMICOLON)
        else
            exp
            match(TokenType::SEMICOLON)
        end
    end

    def exp
        if @token.type == TokenType::ID
            match(TokenType::ID)
            if @token.type == TokenType::ASSIGN
                match(TokenType::ASSIGN)
                exp
            else
                @next_token = @token
                @token = @prev_token
                simple_exp
            end
        else
            simple_exp
        end
    end

    def relop
        if $first["relop"].index(@token.type)
            match(@token.type)
        else
            match(TokenType::ERROR)
        end
    end

    def simple_exp
        add_exp
        while $first["relop"].index(@token.type)
            match(@token.type)
            add_exp
        end
    end

    def add_exp
        term
        while $first["addop"].index(@token.type)
            match(@token.type)
            term
        end
    end

    def term
        factor
        while $first["mulop"].index(@token.type)
            match(@token.type)
            factor
        end
    end

    def factor
        if @token.type == TokenType::LEFT_PAREN
            match(TokenType::LEFT_PAREN)
            exp
            match(TokenType::RIGHT_PAREN)
        elsif @token.type == TokenType::NUM
            match(TokenType::NUM)
        elsif @token.type == TokenType::ID
            match(TokenType::ID)
            if @token.type == TokenType::LEFT_BRACKET
                match(TokenType::LEFT_BRACKET)
                exp
                match(TokenType::RIGHT_BRACKET)
            elsif @token.type == TokenType::LEFT_PAREN
                match(TokenType::LEFT_PAREN)
                args
                match(TokenType::RIGHT_PAREN) 
            end
        else
            match(TokenType::ERROR)
        end
    end

    def args
        if $first["args-list"].index(@token.type)
            args_list
        end
    end

    def args_list
        exp
        while @token.type == TokenType::COMMA
            match(TokenType::COMMA)
            exp
        end
    end

    def print_token(str)
        if $debug
            puts "#{str} #{@token.val}"
        end
    end

    ##
    # Matches the current token type with the expected token type
    ##
    def match(expected)
        if @token.type == expected
            @prev_token = @token
            print_token "accepted"
            if @next_token.nil?
                @token = Scanner.getToken(@input)
            else
                @token = @next_token.clone
                @next_token = nil
            end
        else
            print_token "rejected"
            raise Reject
        end
    end
end
