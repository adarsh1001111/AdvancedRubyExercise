module M1; end
module M2; end
module M3; end

class Module
  def included(klass)
    mod = self
    klass.class_eval do
      @included_modules ||= []
      @included_modules.unshift(mod) unless @ancestors&.include? mod
    end
  end

  def prepended(klass)
    mod = self
    klass.class_eval do
      @prepended_modules ||= []
      @prepended_modules.unshift(mod) unless @prepended_modules.include? mod
    end
  end
end

class Class
  def ancestors
    return @ancestors.dup if @ancestors

    @superclasses ||= []
    @superclasses << superclass.ancestors if superclass
    @ancestors = [*@prepended_modules, self, *@included_modules, *@superclasses].flatten
    @ancestors.dup
  end
end

class A
  include M1, M2
  prepend M3, M2, M2
end

class B < A
end
p A.ancestors
p B.ancestors

class C < B
  prepend M1, M2
  prepend M3
end
p C.ancestors

class D; end
p D.ancestors