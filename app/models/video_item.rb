class VideoItem < GalleryItem
  validates_presence_of :video_url
  def is_video?
    true
  end

  def video_id
    if self.kind == :youtube
      # Check whether Youtube embed code was entered
      doc = Hpricot.parse(self.video_url)

      #Check if there is a movie param
      embed_url = if (element = doc % "//param[@name='movie']")
        element.attributes["value"]
      elsif (element = doc % "//embed") #Check for the movie code in the embed element
        element.attributes["src"]
      end

      #If we have pulled out a URL from the embed code, get the v param
      if embed_url && (match = %r{/v/(\w+)&}.match(embed_url))
        return match[1]
      end

      #If the user entered the video page url
      query_string = self.video_url.split( '?', 2)[1]
      if query_string
        params = CGI.parse(query_string)
        if params.has_key?("v")
          return params["v"][0]
        end
      end
    elsif self.kind == :vimeo      
      #If the user entered the video page url
      return self.video_url.split('/').last      
    end
  end
  
  def kind
    if self.video_url =~ /youtube/
      :youtube
    elsif self.video_url =~ /vimeo/
      :vimeo
    end
  end
  
  def thumbnail_url
    if self.kind == :youtube
      "http://img.youtube.com/vi/#{self.video_id}/default.jpg" 
    elsif self.kind == :vimeo
      # for vimeo thumbnail we need to perform a request to vimeo servers 
      # this is a temporal image for the client
      "" 
    end
  end
    
end

