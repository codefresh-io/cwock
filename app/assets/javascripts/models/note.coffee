define ['backbone'], (Backbone)->
  class Note extends Backbone.Model
    toJSON: ->
      taken_at: @get('taken_at')
      content: @get('content')
