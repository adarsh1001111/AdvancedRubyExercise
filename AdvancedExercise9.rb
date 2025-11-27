# custom Error which is thrown when we find that the filter method is not privately defined
class NoPrivateMethodError < StandardError
  def initialize
    super('filter method must be defined as a private method')
  end
end

# module MyModule which extends the ClassMethods in the class when included or extended
module MyModule
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.extended(base)
    base.extend(ClassMethods)
  end
  # module ClassMethods which contains the class methods we needed to extend in MyClass
  module ClassMethods
    def before_filter(*args, **options)
      @before_filters ||= []
      add_filter(@before_filters, *args, **options)
    end

    def after_filter(*args, **options)
      @after_filters ||= []
      add_filter(@after_filters, *args, **options)
    end

    def action_methods(*method_names)
      @action_methods ||= []

      method_names.each do |method_name|
        next if @action_methods.include?(method_name)

        @action_methods << method_name
        next unless instance_methods(false).include?(method_name)

        wrap_with_filters(method_name)
      end
    end

    def method_added(method_name)
      return if @adding_method || !@action_methods&.include?(method_name)

      wrap_with_filters(method_name)
    end

    private

    def add_filter(store, *args, **options)
      store << {
        methods: args,
        only: options[:only],
        except: options[:except]
      }
    end

    def wrap_with_filters(method_name)
      @adding_method = true

      original_name = :"original_#{method_name}_method"
      alias_method original_name, method_name

      define_method(method_name) do |*args, &blk|
        klass = self.class

        run_filters(klass.instance_variable_get(:@before_filters), method_name)
        result = public_send(original_name, *args, &blk)
        run_filters(klass.instance_variable_get(:@after_filters), method_name)

        result
      end

      @adding_method = false
    end
  end

  private

  def run_filters(filters, method_name)
    return unless filters

    filters.each do |filter|
      next if filter[:only] && !filter[:only].include?(method_name)
      next if filter[:except] && filter[:except].include?(method_name)

      filter[:methods].each do |m|
        if m.is_a?(Proc)
          m.call
        else
          raise NoPrivateMethodError unless private_methods.include?(m)
          send(m)
        end
      end
    end
  end
end

# example class as in question
class MyClass
  include MyModule

  before_filter proc { p 'hi from proc' }
  before_filter :foo, :bar

  after_filter :baz, :foo
  after_filter proc { p 'proc in after filter' }, proc { p 'another proc after filter' }

  action_methods :my_method, :your_method

  def my_method
    p 'my method'
  end

  def your_method
    p 'your method'
  end

  def fake_method
    p 'fake method'
  end

  private

  def foo
    p 'foo'
  end

  def bar
    p 'bar'
  end

  def baz
    p 'baz'
  end
end

MyClass.new.my_method
