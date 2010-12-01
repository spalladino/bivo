require 'test_helper'

class VideoItemTest < ActiveSupport::TestCase

  test "extract vimeo video information" do
    video = VideoItem.new :video_url => 'http://www.vimeo.com/11077331'
    assert_equal :vimeo, video.kind
    assert_equal '11077331', video.video_id
    assert_equal '', video.thumbnail_url
  end
  
  test "extract youtube vide information" do
    video = VideoItem.new :video_url => 'http://www.youtube.com/watch?v=7hvBexeoI38&feature=aso'
    assert_equal :youtube, video.kind
    assert_equal '7hvBexeoI38', video.video_id    
    assert_equal "http://img.youtube.com/vi/7hvBexeoI38/default.jpg", video.thumbnail_url
  end
end
