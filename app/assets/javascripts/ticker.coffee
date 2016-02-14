define ['underscore', 'backbone', 'moment'], (_, Backbone, moment) ->
  class Ticker
    constructor: ->
      _(@).extend Backbone.Events

      tick = =>
        [@that_date, @this_date] = [@this_date, new Date]
        [@that_sec, @this_sec] = [@this_sec, (@this_date).getSeconds()]
        if @this_sec != @that_sec
          [@that_minute, @this_minute] = [@this_minute, moment(@this_date).format('l LT')]
          if @this_minute != @that_minute
            @trigger 'minute', @this_date
            [@that_day, @this_day] = [@this_day, moment(@this_date).format('l')]
            @trigger 'day', @this_date  if @this_day != @that_day
          @trigger 'second', @this_date
        setTimeout tick, 24
      tick()
  # NOTE as if W3C would really have this ;)
  window.ticker ||= new Ticker
