# custom exception when user enters invalid methods
class CustomMethodError < StandardError
  def initialize
    super('Enter the custom methods from the above list only!!')
  end
end

MESSAGE_HASH = {
  method_choose: 'Choose a method: ',
  args_input: 'Enter arguments (separated by space or comma): ',
  methods_defined_display: 'List of methods defined: '
}.freeze

# class to handle user input
class InputHandler
  def initialize(obj)
    @obj = obj
  end

  def execute_all
    show_public_instance_methods
    method_name, args = input_method
    puts "You chose: #{method_name}"
    result = @obj.public_send(method_name, *args)
    puts "Result: #{result}"
  end

  private

  def show_public_instance_methods
    print MESSAGE_HASH[:methods_defined_display]
    p @obj.class.public_instance_methods(false)
  end

  def input(msg)
    print msg
    entered_input = gets.chomp
    case msg
    when MESSAGE_HASH[:method_choose]
      raise CustomMethodError unless @obj.class.public_instance_methods(false).include?(entered_input.to_sym)
    end
    entered_input
  end

  def choose_method
    input(MESSAGE_HASH[:method_choose])
  rescue CustomMethodError => e
    puts e.message
    retry
  end

  def input_method
    method_name = choose_method
    method_to_call = @obj.method(method_name)
    argument_display(method_to_call)
    args = method_to_call.arity.zero? ? [] : input_args
    [method_name, args]
  end

  def argument_display(method_obj)
    method_obj.parameters.each do |type, name|
      case type
      when :req
        puts "#{name} (required)"
      when :opt
        puts "#{name} (optional)"
      when :rest
        puts "*#{name} (variable positional args)"
      when :keyrest
        puts "**#{name} (keywords args)"
      end
    end
  end

  def input_args
    input(MESSAGE_HASH[:args_input]).split(',')
  end
end

# class derived from String
class MyStringClass < String
  def add_text(text = '')
    self << text
  end

  def exclude?(text)
    !include?(text)
  end

  def upcase_concat(*args)
    result = upcase
    args.each { |str| result << str.upcase }
    result
  end
end

print 'Enter initial string: '
msg = gets.chomp
obj = MyStringClass.new(msg)
handler = InputHandler.new(obj)
handler.execute_all