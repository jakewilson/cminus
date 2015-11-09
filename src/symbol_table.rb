class SymbolTable

    def initialize
        @table = {} # symbol table for the current scope
        @next = nil # stores the next symbol table for next scope
        @prev = nil # previous scopes symbol table
    end

    def add id, s
        @table[id] = Symbol_.new(id, s)
    end

    def get id
        @table[id]
    end

    def next=n
        @next = n
    end

    def next
        @next
    end

    def prev=p
        @prev = p
    end

    def prev
        @prev
    end

    def print
        @table.each do |s, sym|
            puts sym
        end
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

    def to_s
        return @name + ":" + @type
    end

end