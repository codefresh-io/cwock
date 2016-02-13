define ['underscore', 'backbone.marionette', 'moment', 'ticker', 'views/day'], (_, Marionette, moment, ticker, DayView) ->

  class CwockView extends Marionette.CompositeView

    template: _.template('<div class="days"></div>')

    childView: DayView

    childViewContainer: '.days'

    childViewOptions: (model)->
      day: model.get('day')
      collection: @notes  # NOTE it filters itself with day

    constructor: (options)->
      options.collection = new Backbone.Collection  # XXX connect
      super

      moment.locale window.navigator.language

      @notes = new Backbone.Collection

      current_note = @notes.add({})

      @listenTo ticker, 'day', (day)->
        @collection.add day: day
      @collection.add {}  # NOTE today
