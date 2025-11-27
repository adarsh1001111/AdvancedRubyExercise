instance_1 = 'string 1'
instance_2 = String.new('string 2')
instance_3 = 'string 3'
instance_4 = 'string 4'
# defining using def.something syntax
def instance_1.speak_your_type
  puts "hi i am instance_1 from class: #{self.class}"
end

# defining by opening eigen class of instance_2
class << instance_2
  def speak_something
    puts "hi i am instance_2 from class: #{self.class}"
  end
end

#defining by opening eigen class of instance_3
instance_3.instance_eval do
  def speak_anything
    puts "hi i am instance_3 from class: #{self.class}"
  end
end

#defining using define_method method on eigen/singleton class as self
instance_4.singleton_class.define_method 'speak' do
  puts "hi i am instance_4 from class: #{self.class}"
end

instance_1.speak_your_type
instance_2.speak_something
instance_3.speak_anything
instance_4.speak