# module MyObjectStore which stores the validated objects
module MyObjectStore
  def self.included(klass)
    klass.extend ClassMethods
    klass.instance_variable_set(:@container, [])
  end

  def validate
    true
  end

  def validate_all
    validate && validate_presence && validate_range_attr
  end

  def validate_presence
    req = self.class.instance_variable_get(:@required)
    req.select do |attr| 
      log_error(attr, "#{attr} not present") if instance_variable_get("@#{attr}").nil? 
    end.empty?
  end
  
  def log_error(attr, msg)
    @logged_errors ||= {}
    (@logged_errors[attr] ||= []) << msg
  end

  def validate_range_attr
    valid = self.class.instance_variable_get(:@valid_range)
    flag = true
    valid.each do |k,v|
      attr = instance_variable_get("@#{k}")
      unless attr
        log_error(attr, "#{k} not present")
        flag = false
      end
      unless (attr >= v[0] && attr <= v[1])
        log_error(k, "#{attr} not in range")
        flag = false
      end
    end
    flag = true
  end

  def save
    saved = false
    if validate_all
      self.class.instance_variable_get(:@container) << self
      saved = true
    end
    display_msg(saved)
  end

  def display_msg(saved)
    p saved ? "#{self} saved" : 'couldn\'t save the object'
  end

  def errors
    @logged_errors.dup
  end
  # module ClassMethods which encapsulates the class methods of the class MyObjectStore would be included in
  module ClassMethods
    include Enumerable
    
    def validates( *args, **kwargs = { presence: true })
      kwargs.each do |k,v|
        klass = "#{k}".capitalize
        (@klasses_added ||= Set.new) << klass
      end
      define_class
    end

    def define_class
      @klasses_added.each do |klass_name|
        klass = const_get("#{klass_name}Validator") rescue const_set("#{klass_name}Validator", Class.new)
        klass.class_eval do
          define_validator(klass_name)
          end
        end
      end
    end

    def define_validator(klass_name)
      case klass_name
      when Presence
        @required ||= []
        (@required << args).flatten!
        define_method :validator
          
        end
          
      end
    end

    def validate_range (*args, **kwargs)
      @valid_range ||= {}
      args.each do |attr|
        @valid_range[attr] = kwargs[:range]
      end
    end

    def each
      @container.each { |obj| yield obj }
    end

    def attr_accessor(*args)
      args.each do |attr|
        define_singleton_method "find_by_#{attr}" do |val|
          @container.select { |obj| val == obj.instance_variable_get("@#{attr}") }
        end
      end
      super
    end

    def validate_presence_of(*args)
      
    end
  end
end

# class Play which includes the MyObjectStore module
class Play
  include MyObjectStore

  attr_accessor :age, :fname, :email, :lname

  validates :fname, :email, presence: true
  validates :age, range:  [18, 60 ]
  validates :email, format: { with: /\A[a-zA-Z]+\z/ }
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
validates :points, numericality: true
validates :email, uniqueness: true
  def validate
    true
  end
end

p p2 = Play.new
p p2.fname = 'abc'
p p2.lname = 'def'
p p2.email = 'adarsh.amit'
p p2.age = 10
p2.save
p p2.errors
p p1 = Play.new
p p1.fname = 'something'
p1.save
p p1.errors
p Play.find_by_fname('something')
p Play.find_by_fname('abc')
p Play.find_by_email('adarsh.amit')
p Play.find_by_fname('something')
p Play.collect
p Play.count
Play.map { |obj| obj }
p Play.map
p Play.errors
# These should return all the objects satisfying the condition
Play.validators #list of classes used to validate the objects
Play.validations # attr: name_valida , ...
Play.count # saved: instantiated:

p1.errors # errors on p1
#name: should , .. , #email: should ... 
p1.valid? #can be saved or not

=begin
a = A.new
b=A.new

a.instance_eval {

define_singleton_method

}
A.instance_eval{
    define
}
Module.nesting []
module A
    X=10
  module B
    
  end
end
module A::B
  
end
=end