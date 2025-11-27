# Concern module when included in a mixin extends itself in that mixin
module Concern
  def self.included(mod)
    return unless mod.class == Module

    mod.singleton_class.prepend(self)
  end

  def included(klass)
    klass.extend(self::ClassMethods)
    super
  end
end

# Mixin module when included in any class , the class can use its class methods and instance methods
module Mixin
  include Concern
  # ClassMethods module inside the Mixin module which encapsulates the ClassMethods needed to be extended in MyClass
  module ClassMethods
    def my_class_method
      p 'this is a class method'
    end
  end

  # All instance methods go here
  def my_instance_method
    p 'instance method'
  end
end

# MyClass which includes the Mixin module
class MyClass
  include Mixin
  my_class_method
  # my_class_method is available as class method
  # my_instance_method is available as instance method
end

MyClass.new.my_instance_method