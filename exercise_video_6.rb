module TraceCalls
    def self.included(klass)
      def klass.method_added(name1)
        return if @_adding_a_method
        @_adding_a_method = true
        original_method = "original #{name1}"
        alias_method original_method, name1
        define_method(name1) do |*args,&blk|
          puts "Calling the method #{name1} with arguments: #{args}"
          result = send(original_method, *args ,&blk)
          puts "result => #{result}"
        end
        @_adding_a_method = false
      end
    end
end

class A
  include TraceCalls
  def method1(a)
    yield + a
  end
end
A.new.method1(10){3}
