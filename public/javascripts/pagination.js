// See http://railscasts.com/episodes/174-pagination-with-ajax
$(function() {
  $(".pagination a").live("click", function() {
    $(".pagination").html("Loading page...");
    $.get(this.href, null, null, "script");
    return false;
  });
});