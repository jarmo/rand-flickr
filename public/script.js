var PhotoRenderer = function(container, photo) {
  this.render = function() {
    $("<img>").load(function() {
      $(this).remove()
      container
        .css("background-image", "url(" + photo.url + ")")
        .find(".caption").html(photo.photoset_title + "<br>" + photo.title).end()
        .fadeIn()
    }).attr("src", photo.url)

    return this
  }
}
