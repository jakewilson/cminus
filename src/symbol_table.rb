class SymbolTable

    def initialize
        @table = {} # symbol table for the current scope
        @next = nil # stores the next symbol table for next scope
        @prev = nil # previous scopes symbol table
    end

    def add id, s
        @table[id] = s
    end

    def get id
        @table[id]
    end

    def next
        @next
    end

end

class Symbol_

    def initialize(name, type)
        @name = name
        @type = type
    end

    def name
        @name
    end

    def type
        @type
    end

end
