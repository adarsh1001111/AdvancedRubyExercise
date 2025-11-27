# ShoppingList class to store the list of items with several methods
class ShoppingList
  attr_reader :list_of_items

  def initialize
    @list_of_items = Hash.new { |h, k| h[k] = Item.new(k) }
  end

  def add(item_name, quantity)
    return unless quantity.positive?

    key = normalize(item_name)
    item = list_of_items[key]
    item.add_quantity(quantity)
    list_of_items[key] = item
  end

  def remove(item_name, quantity)
    return unless quantity.positive?

    key = normalize(item_name)
    item = list_of_items[key]
    return unless item

    item.remove_quantity(quantity)
    list_of_items.delete(key) if item.quantity.zero?
  end

  def items(&blk)
    instance_eval(&blk) if block_given?
  end
  
  def to_s
    list_of_items.values.each do |item|
      puts item
    end
  end

  private

  def normalize(name)
    name.strip.downcase
  end
end

# Item class for Items that will be in the shopping list
class Item
  attr_reader :name, :quantity

  def initialize(name, quantity = 0)
    @name = name.capitalize
    @quantity = quantity
  end

  def add_quantity(amount)
    @quantity += amount
  end

  def remove_quantity(amount)
    @quantity -= amount
    @quantity = 0 if quantity.negative?
  end

  private

  def to_s
    "#{name} => #{quantity}"
  end
end

sl = ShoppingList.new
sl.items do
  add 'TootHpaste', 3
  add 'comPuter', 1
  remove 'toothPaste', 1
  add 'comPuter', 100
end

puts sl
