# class Integer monkey patched to support the .to_roman functionality on Integer instances
class Integer
  ROMAN_SYMBOLS = { I:1, V:5, X:10, L:50, C:100, D:500, M:1000 }.freeze
  def to_roman
    roman = ''
    num = self
    ROMAN_SYMBOLS.to_a.reverse_each do |sym, val|
      (num / val).times { roman << sym.to_s }
      num = num % val
    end
    roman
  end
end

p 9.to_roman