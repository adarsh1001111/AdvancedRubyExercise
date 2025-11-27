module MyModule
  def self.included(klass)
    klass.singleton_class.prepend(ClassMethods)
  end

  def self.extended(klass)
    klass.singleton_class.prepend(ClassMethods)
  end
end

module ClassMethods
  def around_filter(method_name)
    @around_filter = method_name
  end

  def method_added(method_sym)
    return if @adding_method
    wrap_it(method_sym) if @action_methods&.include? method_sym
  end
  
  def wrap_it(method_sym)
    @adding_method = true
      alias_method "original_#{method_sym}", method_sym
      define_method method_sym do |*args, &blk|
        send(self.class.instance_variable_get(:@around_filter)) do
          send("original_#{method_sym}", *args, &blk)
        end
      end
      @adding_method = false
  end

  def action_methods(*args)
    @action_methods ||= []
    args.each do |method_name|
      @action_methods << method_name
      wrap_it if instance_methods(false).include?method_name
    end
  end
end

class Abc
  include MyModule
  action_methods :mymethod
  around_filter :measure_execution_time

  def mymethod
    p "mymethiod"
  end
  
  private

  def measure_execution_time
    p start_time = Time.now
    yield  # This executes the action
    p end_time = Time.now
    p duration = end_time - start_time
  end
end
Abc.new.mymethod

