class A
    def method_added(method_sym)
      method_base = method_sym.to_s.delete_suffix('_logging')
      if methods.include? method_base.to_sym
        p "#{method_base} has been called"
        public_send("#{method_base}",*args)
      
    else
      super
    end
    end
    def xyz
        10
    end
    def abc(x,y)
        20
    end
    def _logging
        5
    end
end

p A.new.xyz_logging
p A.new.abc_logging(1,2)
p A.new._logging_logging
