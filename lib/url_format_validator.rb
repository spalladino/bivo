class UrlFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /[a-zA-Z\-_][a-zA-Z0-9\-_]*/
      object.errors[attribute] << (options[:message] || "is not formatted properly")
    end
  end
end
