##
# parser.rb
# Author: Jake Wilson
# Date: 10/4/15
##

class Parser

    def initialize(input)
        @input = input
        @token = Scanner.getToken(input)
        @var_dec = false # flag for whether we're in a variable declaration
        @main_defined = false
        @table = SymbolTable.new
        @current_func = ''
        @scope_added = false
        @args = []
        @params = false
        @scope = 0
    end

    def parse
        prog
        raise Reject if !@main_defined
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
                @main_defined = false if @main_defined
                @current_func = ''
                match(TokenType::SEMICOLON)

            when TokenType::LEFT_PAREN # in function
                @table.get(@current_func).is_func = true
                match(TokenType::LEFT_PAREN)
                @scope_added = true
                add_scope
                params
                match(TokenType::RIGHT_PAREN)
                compound_stmt
                
            when TokenType::LEFT_BRACKET
                @main_defined = false if @main_defined
                @current_func = ''
                match(TokenType::LEFT_BRACKET)
                match(TokenType::NUM)
                match(TokenType::RIGHT_BRACKET)
                match(TokenType::SEMICOLON)
            else
                raise Reject
        end
    end

    def var_dec
        @var_dec = true
        type_spec_id
        if @token.type == TokenType::SEMICOLON
            match(TokenType::SEMICOLON)
        else
            match(TokenType::LEFT_BRACKET)
            match(TokenType::NUM)
            match(TokenType::RIGHT_BRACKET)
            match(TokenType::SEMICOLON)
        end
        @var_dec = false
    end

    def type_spec
        case @token.val
            when 'void'
                raise Reject if @var_dec
            when 'int', 'float'
                # accept
            else
                raise Reject
        end
    end

    def type_spec_id
        type_spec
        type = @token.val
        match(@token.type)

        # ensure main is defined once
        if @token.val == 'main' and !@var_dec
            @main_defined = true
        end

        # attempted re-declaration
        if @table.get(@token.val) 
            raise Reject
        end

        @table.add(@token.val, type)
        puts "adding #{@token.val} to the table #{@scope}" if $debug

        if @current_func != '' and @params
            #puts @scope.to_s
            @table.prev.get(@current_func).add_arg(Symbol_.new(@token.val, type))
            puts "added arg " + @token.val + " to function " + @current_func if $debug
        end

        @current_func = @token.val if !@var_dec

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
        @params = true
        param
        while (@token.type == TokenType::COMMA)
            match(TokenType::COMMA)
            param
        end
        @params = false
    end

    def param
        @var_dec = true
        type_spec_id
        if (@token.type == TokenType::LEFT_BRACKET)
            match(TokenType::LEFT_BRACKET)
            match(TokenType::RIGHT_BRACKET)
        end
        @var_dec = false
    end

    def compound_stmt
        match(TokenType::LEFT_BRACE)
        # add a new scope everytime we see a { (except when in a function header)
        add_scope if !@scope_added 
        @scope_added = false
        local_dec
        stmt_list
        match(TokenType::RIGHT_BRACE)
        puts @scope.to_s if $debug
        @table.print if $debug
        rem_scope
        puts @scope.to_s if $debug
        @table.print if $debug
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
                raise Reject if @table.find(@token.val) == nil
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
        puts "#{str} #{@token.val} current_func: #{@current_func}" if $debug
    end

    def print_expected(str)
        puts "expected #{str} current_func: #{@current_func}" if $debug
    end

    def add_scope
        @table = @table.next = SymbolTable.new
        @scope += 1
    end

    def rem_scope
        @table = @table.prev
        @scope -= 1
    end

    def print_table
        if $debug then @table.print end
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
