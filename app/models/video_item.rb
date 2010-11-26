class VideoItem < GalleryItem
 validates_presence_of :video_url
 def is_video?
    true
 end

 def video_id
    video_code = self.video_url
    unless video_code.nil?
      # Check whether Youtube embed code was entered
      doc = Hpricot.parse(video_code)

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
      query_string = video_code.split( '?', 2)[1]
      if query_string
        params = CGI.parse(query_string)
        if params.has_key?("v")
          return params["v"][0]
        end
      end
    end
  end

  def thumbnail_url
    "http://img.youtube.com/vi/#{self.video_id}/default.jpg"
  end
  
end

