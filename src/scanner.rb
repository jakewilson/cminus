class TokenType
    ID             = 0
    NUM            = 1
    ELSE           = 2
    IF             = 3
    INT            = 4
    RETURN         = 5
    VOID           = 6
    WHILE          = 7
    FLOAT          = 8
    PLUS           = 9
    MINUS          = 10
    TIMES          = 11
    DIVIDE         = 12
    LT             = 13
    LTE            = 14
    GT             = 15
    GTE            = 16
    IS_EQUAL       = 17
    NOT_EQUAL      = 18
    ASSIGN         = 19
    SEMICOLON      = 20
    COMMA          = 21
    LEFT_PAREN     = 22
    RIGHT_PAREN    = 23
    LEFT_BRACE     = 24
    RIGHT_BRACE    = 25
    LEFT_BRACKET   = 26
    RIGHT_BRACKET  = 27
    BLK_CMNT_BEG   = 28
    END_CMNT_END   = 29
    EOF            = 30
end

class State
    START   = 0
    IN_ID   = 1
    IN_NUM  = 2
    DONE    = 3
end


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

            
        end

    end # end def

end
