module HomeHelper
  def link_to_static_page(id)
    if @id == id
      html = { :class => 'leftSelect' }
    else
      html = {}
    end
    
    link_to static_page_title(id), static_page(id), html
  end
  
  def static_page_title(id)
    case id
      when :who_we_are         then _("Who we are?")
      when :how_it_works       then _("How Does it Work?")
      when :faq                then _("FAQ")
      when :our_team           then _("Our team")
      when :contact_us         then _("Contact Us")

      when :fund_raisers       then _("Fund Raisers")
      when :social_initiatives then _("Social Initiatives")

      when :spread_the_word    then _("Spread the Word")
      when :volunteer          then _("Volunteer")
    end
  end
end
