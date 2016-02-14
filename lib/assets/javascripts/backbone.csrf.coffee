define ['jquery', 'backbone'], ($, Backbone)->
  # NOTE https://github.com/shuvalov-anton/backbone-rails-sync
  Backbone._sync = Backbone.sync
  Backbone.sync = (method, model, options)->
    unless options.noCSRF
      beforeSend = options.beforeSend

      options.beforeSend = (xhr)->
        token = $('meta[name="csrf-token"]').attr('content')
        xhr.setRequestHeader 'X-CSRF-Token', token  if token
        beforeSend.apply @, arguments  if beforeSend

    Backbone._sync arguments...
