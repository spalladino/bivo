class Shop < ActiveRecord::Base
  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/


  enum_attr :status, %w(^inactive active deleted)

end

