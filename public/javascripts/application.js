// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function disableAndContinue(element, text) {
    window.setTimeout(function(){
        $(element).attr({ disabled:true, value: text});
    },0);
}

// gallery related scripts

$(function(){
	$(".submit_form").live('click', function(){
 		$(this).closest("form").submit();
    	return false;
	});


	$('.gallery .thumbnails img').click(function(){
		var _this = $(this);
		var gallery = _this.closest('.gallery');
		var view = $('.view', gallery);
		var kind = _this.attr('data-kind');

		// mark thumbnail as current
		$('.current', gallery).removeClass('current');
		_this.addClass('current');

		// render full size content in ".gallery .view"
		// show/hide didn't work, so add/remove is used
		var content;
		if (kind == 'photo') {
			content = $('<img style="height:183px; width:311px">').attr('src', _this.attr('data-url'));
		} else if (kind == 'youtube') {
			content = $('<iframe>')
				.attr('src', 'http://www.youtube.com/embed/' + _this.attr('data-video_id') + '?rel=0')
				.attr('type', 'text/html')
				.attr('width', '223')
				.attr('height', '183')
				.attr('frameborder', '0');
		} else if (kind == 'vimeo') {
			content = $('<iframe>')
				.attr('src', 'http://player.vimeo.com/video/' + _this.attr('data-video_id') + '?title=0&amp;byline=0&amp;portrait=0&amp;autoplay=1')
				.attr('type', 'text/html')
				.attr('width', '311')
				.attr('height', '175')
				.attr('frameborder', '0');
		}

		view.html(content);
		$(content).css('margin-top', (view.height() - content.height()) / 2);
    $(content).css('margin-left', (view.width() - content.width()) / 2);
	});

	// load first item
	$('.gallery .thumbnails img:first').click();

	// load vimeo thumbnails
	$('.gallery .thumbnails img').each(function(){
		// load thumbnails
		var img = $(this);
		if (img.attr('data-kind') == 'vimeo') {
			var url = "http://vimeo.com/api/v2/video/" + img.attr('data-video_id') + ".json?callback=showVimeoThumbnail";
			var script = $('<script src="' + url + '">');
			img.before(script);
		}
	});
});

// load vimeo thumbnails callback
// HACK: assume just one gallery is loaded
function showVimeoThumbnail(data){
	img = $('.gallery .thumbnails img[data-video_id=' + data[0].id + ']');
    $(img).attr('src',data[0].thumbnail_small);
}

