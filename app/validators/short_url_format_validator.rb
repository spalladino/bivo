class ShortUrlFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /^[a-zA-Z][a-zA-Z0-9\-_]*$/
      object.errors[attribute] << (options[:message] || "#{value} is not formatted properly")
    end
  end
end
