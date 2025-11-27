# MyModule is the module which is meant to be extended in the class to support chained_aliasing
module MyModule
  def chained_aliasing(original_method, extension)
    method_base, exclamation = extract_exclamation_from_method(original_method)
    method_with_, method_without_ = get_with_without_names(method_base, extension, exclamation)

    alias_method method_without_, original_method

    access = get_access_modifier(original_method)

    alias_method original_method, method_with_
    send(access, original_method, method_with_)
  end

  def extract_exclamation_from_method(method_name)
    method_base = method_name.to_s.sub(/([?!=])\Z/, '')
    exclamation = Regexp.last_match(1)
    [method_base, exclamation]
  end

  def get_with_without_names(method_base, extension, exclamation)
    [
      "#{method_base}_with_#{extension}#{exclamation}",
      "#{method_base}_without_#{extension}#{exclamation}"
    ]
  end

  def get_access_modifier(method_symbol)
    if private_method_defined?(method_symbol)
      :private
    elsif protected_method_defined?(method_symbol)
      :protected
    else
      :public
    end
  end
end

# class Hello is a example class
class Hello
  def greet
    puts 'hello'
  end
end

say = Hello.new
say.greet

# reopening to show how chained_aliasing works
class Hello
  extend MyModule

  def greet_with_logger
    puts '--logging start'
    greet_without_logger
    puts '--logging end'
  end

  chained_aliasing :greet, :logger
end

say = Hello.new
say.greet
say.greet_with_logger
say.greet_without_logger
