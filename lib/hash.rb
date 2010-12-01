class Hash
  # keys should be symbolized (try symbolize_keys before executing it) before using it.
  def to_struct
    Struct.new(*keys).new(*values)
  end
end
