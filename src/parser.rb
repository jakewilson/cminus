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
    end

    def prog
        dec_list
    end

    def dec_list
        dec
        while $first["dec"].index(@token.type)
            dec
        end
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
                match(TokenType::LEFT_BRACKET)
                match(TokenType::NUM)
                match(TokenType::RIGHT_BRACKET)
                match(TokenType::SEMICOLON)
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
            when 'int', 'float', 'void'
                match(@token.type)
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
            if @token.type == TokenType::ID
                match(TokenType::ID)
                if @token.type == TokenType::COMMA
                    match(TokenType::COMMA)
                    param_list
                end
            end
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
            factor
            if @token.type == TokenType::ASSIGN
                match(TokenType::ASSIGN)
                exp
            else
                rotcaf
            end
        else
            simple_exp
        end
    end

    # start from factor and go backwards
    def rotcaf
        while $first["mulop"].index(@token.type)
            match(@token.type)
            factor
        end
        while $first["addop"].index(@token.type)
            match(@token.type)
            term
        end
        while $first["relop"].index(@token.type)
            match(@token.type)
            add_exp
        end
    end

    def var
        match(TokenType::ID)
        if @token.type == TokenType::LEFT_BRACKET
            match(TokenType::LEFT_BRACKET)
            exp
            match(TokenType::RIGHT_BRACKET)
        end
    end

    def relop
        if $first["relop"].index(@token.type)
            match(@token.type)
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
        case @token.type
            when TokenType::LEFT_PAREN
                match(TokenType::LEFT_PAREN)
                exp
                match(TokenType::RIGHT_PAREN)
            when TokenType::NUM, TokenType::FLOAT_NUM
                match(TokenType::NUM)
            when TokenType::ID
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
                raise Reject
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

    def print_expected(str)
        if $debug
            puts "expected #{str}"
        end
    end

    ##
    # Matches the current token type with the expected token type
    ##
    def match(expected)
        # We want to accept a float anytime a num is accepted
        if @token.type == TokenType::FLOAT_NUM && expected == TokenType::NUM
            expected = TokenType::FLOAT_NUM
        end
        if @token.type == expected
            print_token "accepted"
            @token = Scanner.getToken(@input)
        else
            print_token "rejected"
            print_expected expected
            raise Reject
        end
    end
end
