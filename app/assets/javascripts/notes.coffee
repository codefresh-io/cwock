define ['views/cwock'], (CwockView)->
  init: ->
    window.app_view = new CwockView(el: '#cwock')  if $('#cwock').parents('html')[0]
