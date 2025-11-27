require 'csv'

class DynamicClass
  def initialize(file_name)
    @klass_name = file_name.capitalize.chomp('.csv')
    @file_data = CSV.read(file_name, headers: true)
    @headers = @file_data.headers
  end

  def setup_class_and_return_objects
    create_klass
    define_attributes
    create_objects
  end

  private

  def create_klass
    @klass_obj = Object.const_set(@klass_name, Class.new)
    initialize_klass
  end

  def initialize_klass
    headers = @headers
    @klass_obj.define_method(:initialize) do |row|
        headers.each do |attr|
          send("#{attr}=", row[attr])
        end
    end
  end

  def define_attributes
    headers = @headers
    @klass_obj.class_eval do
      attr_accessor(*headers)
      end
  end

  def create_objects
    @file_data.map { |row| @klass_obj.new(row) }
  end
end

file_name = ARGV[0]
dynamic_class = DynamicClass.new(file_name)

objects = dynamic_class.setup_class_and_return_objects
p objects 
