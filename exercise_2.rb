# module AttrAccessor for encapsulating customised attribute accessor defining methods
module AttrAccessor
  def myattr_accessor(*ins_sym)
    dynamic_methods = []
    ins_sym.each do |symbol|
      getter = define_method(symbol) do
        instance_variable_get("@#{symbol}")
      end

      setter = define_method("#{symbol}=") do |val|
        instance_variable_set("@#{symbol}", val)
      end
      dynamic_methods << getter << setter
    end
    dynamic_methods
  end
end

# class A for testing working of our custom attribute accessors
class A
  extend AttrAccessor
  myattr_accessor :a, :b
end

p obj = A.new
p obj.a
p obj.a = 100
p obj.b
p obj2 = A.new
puts obj2.a
p obj2.a = 100
puts obj2.a