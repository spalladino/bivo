class ShopSubdomain
  def self.matches?(request)  
    request.subdomain.present? && request.subdomain == 'shop'
  end
end

class MainSite
  def self.matches?(request)  
    !request.subdomain.present? || request.subdomain == 'www'
  end
end
