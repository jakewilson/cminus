# types.rb
#
# Author: Jake Wilson
# Date: 08/29/15

$keywords = ['else', 'if', 'int', 'void', 'return', 'while', 'float']

class Token
    def initialize(type, val)
        @type = type
        @val = val
    end

    def type
        @type
    end

    def val
        @val
    end

    def show
        puts @type
        puts @val
    end
end

class TokenType
    ID             = 0
    NUM            = 1
    ELSE           = 2
    IF             = 3
    INT            = 4
    VOID           = 5
    RETURN         = 6
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
    ERROR          = 31
    FLOAT_NUM      = 32
end

class Reject < RuntimeError
end
