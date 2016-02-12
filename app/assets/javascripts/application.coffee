require ['jquery', 'notes'], ($, Notes) ->
  # NOTE the only running point, postponed until all dependencies are loaded
  $ ->
    Notes.init()

    # NOTE a poor man's routing
    if window.app_view
      window.app_view.render()
    else
      alarm 'Where am I??'
