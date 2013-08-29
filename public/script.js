var PhotoRenderer = function(container, photo) {
  this.render = function() {
    $("<img>").load(function() {
      $(this).remove()
      container
        .css("background-image", "url(" + photo.url + ")")
        .find(".caption").html(photo.photoset.title._content + "<br>" + photo.title).end()
        .fadeIn()
      $("#loader").remove()
    }).attr("src", photo.url)

    return this
  }
}
