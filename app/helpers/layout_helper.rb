module LayoutHelper
  
  def title(page_title)
    @content_for_title = page_title.to_s
  end
  
end