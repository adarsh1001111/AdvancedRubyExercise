# Parser module to encapsulate all methods related to parsing the string
module StringParser
  FLOAT_INT_REGEX = /\A\d+(\.\d+)?\z/.freeze
  def parse_all(first, operator, second)
    { operand1: string_to_float(first),
      operand2: string_to_float(second),
      operator: string_to_symbol(operator) }
  end

  def string_to_float(arg)
    raise ArgumentError unless arg.match? FLOAT_INT_REGEX

    arg.to_f
  end

  def string_to_symbol(arg)
    arg[1..-1].to_sym
  end
end
# class Calculator to calculate the result of input string
class Calculator
  include StringParser
  def calculate(first, operator, second)
    values = parse_all(first, operator, second)
    [values[:operand1], values[:operand2]].reduce(values[:operator])
  end
end

begin
  input = ARGV
  print 'Please provide an input' if input.empty?
  input_arr = input[0].split(',').map(&:strip)
  calculator1 = Calculator.new
  result = calculator1.calculate(input_arr[0], input_arr[1], input_arr[2])
  if (result % 1).zero?
    print result.to_i
  else
    print format('%<value>.2f', value: result)
  end
rescue ArgumentError
  p 'Input contains an Invalid Number'
end