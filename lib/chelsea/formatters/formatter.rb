class Formatter
    def get_results
        raise 'must implement get_results method in subclass'
    end
    
    def do_print
        raise 'must implement do_print method in subclass'
    end
end