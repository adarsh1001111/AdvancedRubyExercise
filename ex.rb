# class A for testing the Dynamic Method defining and removing functionality
class A
  DYNAMIC_METHODS = %i[hello bye].freeze
  singleton_class.attr_accessor :a

  def self.create_bye_method
    define_method :bye do
      p 'hi from bye'
    end
  end

  def self.create_hello_method
    define_method :hello do
      p 'hello'
    end
  end

  def self.instance_variable_set(instance_var, value)
    super
    def_or_rem_dynamic_methods
  end

  def self.def_or_rem_dynamic_methods
    def_or_rem = @a ? 'define' : 'remove'
    send("#{def_or_rem}_dynamic_methods")
  end

  def self.define_dynamic_methods
    DYNAMIC_METHODS.each do |method_name|
      send("create_#{method_name}_method") unless instance_methods(false).include?(method_name)
    end
  end

  def self.remove_dynamic_methods
    DYNAMIC_METHODS.each do |method_name|
      remove_method(method_name) if instance_methods(false).include?(method_name)
    end
  end
end

A.instance_variable_set(:@a, 10)
p A.instance_methods(false)
A.new.hello
p A.instance_methods(false)
A.instance_variable_set(:@a, nil)
p A.instance_methods(false)
A.new.hello