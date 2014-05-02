var PhotoRenderer = function(container, photo) {
  bindEvents();

  this.render = function() {
    startProgress()
    renderImage(photo)

    return this
  }

  function bindEvents() {
    $("a").click($.proxy(renderNewImage, this))

    $(window).on("popstate", $.proxy(renderImageFromHistory, this))
  }

  function renderImage(photo) {
    var dfd = $.Deferred()

    loadPhoto(photo).done(function() {
      $(this).remove()

      container.fadeOut(function() {
        $(this)
          .css("background-image", "url(" + photo.url + ")")
          .find(".caption").html(photo.photoset.title._content + "<br>" + photo.title + "<br>" + photo.ownername).end()
          .fadeIn()
      })

      NProgress.done()
      dfd.resolve()
    })

    this.nextRandomImage = getRandomImageJSON()

    return dfd
  }

  function renderNewImage(ev) {
    ev.preventDefault()

    startProgress()

    var photoRequest = this.nextRandomImage || getRandomImageJSON()
    photoRequest.done(replaceCurrentImage)
  }

  function getRandomImageJSON() {
    var photoJSONUrl = $("a").attr("href") + ".json"
    return $.getJSON(photoJSONUrl).done(loadPhoto)
  }

  function loadPhoto(photo) {
    var dfd = $.Deferred()
    $("<img>").load(function() { $(this).remove(); dfd.resolve() }).attr("src", photo.url)    

    return dfd
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
