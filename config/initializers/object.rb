
class Object
  def define_accessor(name, value = nil)
    self.class_eval { attr_accessor_with_default name, value }
  end
end