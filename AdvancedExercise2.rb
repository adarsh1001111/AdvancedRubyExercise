module UserInput
  def take_all_inputs
    class_name = input_class_name
    method_name = input_method_name
    method_body =  input_method_body
    [class_name, method_name, method_body]
  end

  def input_class_name
    print 'Please enter the class name: '
    gets.chomp
  end

  def input_method_name
    print 'Please enter the method name you wish to define:'
    gets.chomp
  end

  def input_method_body
    print 'Please enter the method\'s code:'
    gets
  end
end

module InputRunner
  def execute_all(class_name, method_name, method_body)
    new_class = DynamicClass.new(class_name)
    new_class.def_method(method_name, method_body)
    puts message_for_user(class_name, method_name)
    new_class.call(method_name)
  end

  def message_for_user(class_name, method_name)
    "Hello, Your class #{class_name} with method #{method_name} is ready. Calling: #{class_name}.new.#{method_name}:"
  end
end

class DynamicClass
  def initialize(class_name)
    @class_name = class_name
    @class_object = Object.const_set(class_name,Class.new)
    @instance = @class_object.new
  end

  def def_method(method_name, method_body)
    @class_object.class_eval do
      define_method(method_name){instance_eval(method_body)}
    end
  end

  def call(method_name)
    @instance.send(method_name)
  end
end

Object.include UserInput,InputRunner
execute_all(*take_all_inputs)