var PhotoRenderer = function(container, photo) {
  bindEvents();

  this.render = function() {
    startProgress()
    renderImage(photo)

    return this
  }

  function bindEvents() {
    $("a").click(renderNewImage)

    $(window).on("popstate", renderImageFromHistory)
  }

  function renderImage(photo) {
    var dfd = $.Deferred()

    $("<img>").load(function() {
      $(this).remove()

      container
        .css("background-image", "url(" + photo.url + ")")
        .find(".caption").html(photo.photoset.title._content + "<br>" + photo.title + "<br>" + photo.ownername).end()
        .fadeIn()

      NProgress.done()
      dfd.resolve()
    }).attr("src", photo.url)

    return dfd
  }

  function renderNewImage(ev) {
    ev.preventDefault()

    startProgress()

    var photoJsonUrl = window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + $("a").attr("href") + ".json"
    $.getJSON(photoJsonUrl).done(replaceCurrentImage)
  }

  function renderImageFromHistory() {
    if (!event.state) return

    startProgress()
    renderImage(event.state)
  }

  function replaceCurrentImage(photo) {
    renderImage(photo).done(function() {
      history.pushState(photo, "", photo.browser_url)      
    })
  }

  function startProgress() {
    NProgress.configure({minimum: 0.3}).start()    
  }
}
