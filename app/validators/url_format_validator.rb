class UrlFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ %r(^((http|https)://)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?/.*)?$)ix
      object.errors[attribute] << (options[:message] || "is not formatted properly")
    end
  end
end
