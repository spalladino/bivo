class Array
  #wraps each element of the array with a tag
  #TODO: add behaviour to pass args like class or style if needed  
  def wrap_each_with_tag!(tag)
    map!{|x| "<#{tag.to_s}>#{x}</#{tag.to_s}>"}
  end
end
