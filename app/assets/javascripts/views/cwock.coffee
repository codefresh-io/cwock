define ['underscore', 'backbone.marionette', 'moment', 'ticker', 'views/day', 'models/note_collection'], (_, Marionette, moment, ticker, DayView, NoteCollection) ->

  class CwockView extends Marionette.CompositeView

    template: _.template('<div class="days"></div>')

    childView: DayView

    childViewContainer: '.days'

    childViewOptions: (model)->
      day: model.get('day')
      collection: @notes  # NOTE it filters itself with day

    constructor: (options)->
      options.collection = new Backbone.Collection
      super

      moment.locale window.navigator.language

      @notes = new NoteCollection
      _.defer => @notes.fetch()
      @listenTo @notes, 'sync', (note)->
        @current_note = @notes.add({})  if !@current_note || note == @current_note

      @listenTo ticker, 'day', (day)->
        @collection.add day: day
      @collection.add {}  # NOTE today
