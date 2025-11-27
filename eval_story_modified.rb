require 'set'

module MyObjectStore
  def self.included(klass)
    klass.extend ClassMethods
    klass.instance_variable_set(:@container, [])
    klass.instance_variable_set(:@validations, Hash.new { |h, k| h[k] = [] })
    klass.instance_variable_set(:@validators, Set.new)
  end
  
  def get_validator_class
    self.class.const_get("#{type.to_s.capitalize}Validator")
  end

  def validate_all
    @logged_errors = {}
    can_be_saved = true

    self.class.instance_variable_get(:@validations).each do |attr, validations|
      validations.each do |validation|
        type = validation[:type]
        validator_class = get_validator_class
        validator = validator_class.new

        unless validator.validate(self, attr, validation[:rule])
          log_error(attr, "#{attr} failed #{type} validation")
          can_be_saved = false
        end
      end
    end
    can_be_saved
  end

  def valid?
    validate_all
  end

  def save
    if valid?
      self.class.instance_variable_get(:@container) << self
      puts "#{self} saved successfully"
      true
    else
      puts "couldn't save #{self}"
      false
    end
  end

  def log_error(attr, msg)
    @logged_errors ||= {}
    (@logged_errors[attr] ||= []) << msg
  end

  def errors
    (@logged_errors || {}).dup
  end

  module ClassMethods
    include Enumerable

    def each
      @container.each{ |saved_obj| yield saved_obj }
    end

    def attr_accessor(*attrs)
      super
      attrs.each do |attr|
        define_singleton_method("find_by_#{attr}") do |val|
          @container.select { |obj| obj.instance_variable_get("@#{attr}") == val }
        end
      end
    end

    def validates(*attrs, **options)
      options.each do |type, rule|
        klass_name = "#{type.to_s.capitalize}Validator"

        unless const_defined?(klass_name)
          const_set(klass_name, validator_for(type))
          @validators << klass_name
        end

        attrs.each do |attr|
          @validations[attr] << { type: type, rule: rule }
        end
      end
    end

    def validator_for(type)
      VALIDATOR_DEFINITIONS[type] || default_validator(type)
    end

    def default_validator(type)
      Class.new do
        define_method(:validate) do |obj, attr, rule|
          true
        end
      end
    end

    VALIDATOR_DEFINITIONS = {
      presence: Class.new do
        def validate(obj, attr, rule)
          val = obj.instance_variable_get("@#{attr}")
          rule ? !val.nil? && !(val.respond_to?(:empty?) && val.empty?) : val.nil?
        end
      end,

      range: Class.new do
        def validate(obj, attr, rule)
          val = obj.instance_variable_get("@#{attr}")
          val && (val >= rule[0] && val <= rule[1])
        end
      end,

      format: Class.new do
        def validate(obj, attr, rule)
          val = obj.instance_variable_get("@#{attr}")
          val && rule[:with] && val =~ rule[:with]
        end
      end,

      length: Class.new do
        def validate(obj, attr, rule)
          val_str = obj.instance_variable_get("@#{attr}").to_s
          return true unless rule.is_a?(Hash)

          if rule[:minimum] && val_str.length < rule[:minimum]
            false
          elsif rule[:maximum] && val_str.length > rule[:maximum]
            false
          elsif rule[:in] && !rule[:in].include?(val_str.length)
            false
          elsif rule[:is] && val_str.length != rule[:is]
            false
          else
            true
          end
        end
      end,

      numericality: Class.new do
        def validate(obj, attr, rule)
          val = obj.instance_variable_get("@#{attr}")
          val.is_a?(Numeric)
        end
      end,

      uniqueness: Class.new do
        def validate(obj, attr, rule)
          container = obj.class.instance_variable_get(:@container)
          val = obj.instance_variable_get("@#{attr}")
          !container.any? { |saved_obj| saved_obj.instance_variable_get("@#{attr}") == val }
        end
      end
    }.freeze

    def validators
      @validators.to_a
    end

    def validations
      @validations.dup #taaki koi user can't modify this bahar se
    end
  end
end

class Play
  include MyObjectStore

  attr_accessor :age, :fname, :email, :lname, :name, :bio, :password, :registration_number, :points

  validates :fname, :email, presence: true
  validates :age, range: [18, 60]
  validates :email, format: { with: /\A[a-zA-Z]+\z/ }
  validates :fname, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
  validates :points, numericality: true
  validates :email, uniqueness: true
end
p Play.constants
p1 = Play.new
p1.fname = 'abc'
p1.email = 'adarsh'
p1.age = 19
p1.points = 20
p1.password = 'adarsh'
p1.registration_number = 123456
p1.save # ye save hona chahiye
p p1.errors # should log empty hash

p2 = Play.new
p2.fname = 'def' 
p2.email = 'adarsh' # uniquess fail krna chahiye
p2.age = 30
p2.points = 'abc'   # not numerical
p2.save # password fail and registration no. fail, points bhi fail
p p2.errors # p2 ke logged errors return hone chahiye

puts "Validators: #{Play.validators}" # rturn all the validators defined on the reciever class
puts "Validations: #{Play.validations}" # return all attribute validation hash like {fname: [ { type: presence, rule: true }]}
puts "Count: #{Play.count}" # work krna chahiye even count is not defined , so Using Enumerable for Play
puts "Find by fname('abc'): #{Play.find_by_fname('abc')}" # find_by_attr defines when attr_accessor :attr runs for that attr
