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

    def find id
        table = self
        return @table[id] if @table[id]
        while table != nil and table.get(id) == nil
            table = table.prev
        end
        return table.get(id) if table != nil
        return nil
    end

    def next=n
        @next = n
        @next.prev = self
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

    def initialize(name, type, is_func = false, is_array = false)
        @name = name
        @type = type
        @is_func = is_func
        @args = []
        @is_array = is_array
    end

    def name
        @name
    end

    def type
        @type
    end

    def is_func
        @is_func
    end

    def is_func=f
        @is_func = f
    end

    def args
        @args
    end

    def add_arg a
        @args << a
    end

    def is_array
        @is_array
    end

    def is_array=a
        @is_array = a
    end

    def to_s
        ret = @name + ":" + @type.to_s
        ret += "\nfunction: " + @is_func.to_s if @is_func
        ret += "\n" + "args: " + args.join(" ") if @is_func
        return ret
    end

end
