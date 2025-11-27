
def xyz
    3
end

class 
    def a1;end
    def b1;end
end

a = A.new

a.abc

A.send(:xyz)

#a (abc) -> send(:xyz) _> a.xyz -> #a ->A -> Object

def a.xyz
    3
end

class << a
  def abc
    send(:xyz)
  end
end

a.singleton_class.define_method :xyz { 3 }
class A
    def self.xyz
    end
end

class B;end
class << B
  class << self
    def xyz
      puts 5
    end
  end
end

class << B
    xyz
end