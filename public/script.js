var PhotoRenderer = function(container, photo) {
  this.render = function() {
    NProgress.configure({minimum: 0.3}).start();

    $("<img>").load(function() {
      $(this).remove()
      container
        .css("background-image", "url(" + photo.url + ")")
        .find(".caption").html(photo.photoset.title._content + "<br>" + photo.title + "<br>" + photo.ownername).end()
        .fadeIn()
      NProgress.done();
    }).attr("src", photo.url)

    return this
  }
}
