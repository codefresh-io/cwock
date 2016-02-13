define ['underscore', 'backbone.marionette', 'moment', 'ticker', 'views/note'], (_, Marionette, moment, ticker, NoteView) ->

  class DayView extends Marionette.CompositeView

    className: 'day'

    template: _.template(
      '<div class="title-holder"></div><div class="title"><div class="dow"><%= dow %></div><div class="date"><%= date %></div><div class="ref"><%= ref %></div></div>' +
      '<div class="notes-scale">' +
      '<div class="time-scale">' +
        ("<div class='hour'>#{moment().startOf('day').add(h, 'hours').format('LT')}</div>" for h in [0..23]).join('') +
      '</div>' +
      '<div class="notes"></div>' +
      '</div>'
    )

    serializeData: ->
      dow: @day_mom.format('dddd')
      date: @day_mom.format('ll')
      ref: /^(\D+)\D/.exec(@day_mom.calendar(new Date))[0]

    filter: (child)->
      @day_date ||= @day_mom.format('l')
      moment(child.get 'taken_at').format('l') == @day_date

    childView: NoteView

    childViewContainer: '.notes'

    childViewOptions: ->
      parentView: @

    constructor: (options)->
      @day_mom = moment(options.day)

      # XXX experimental monkey-patching the filtering functionality for dynamic behaviour
      [@filter, @patchedFilter] = [null, @filter]
      [@original_collection, options.collection] = [options.collection, new options.collection.constructor]

      super

      @listenTo @original_collection, 'add change remove', @onSet
      @onSet()

      # XXX must be in onAttach, but couldn't get it working
      @listenTo ticker, 'day', =>
        @render()  if @rendered  # NOTE to re-render the title mostly

    onRender: ->
      unless @rendered
        @onResizeCallback = => @onResize arguments...
        $(window).on 'resize', @onResizeCallback

      _.defer @onResizeCallback

      @rendered = true

    onResize: ->
      @$('.title').css(
        _(@$('.title-holder').offset()).extend
          width: @$('.title-holder').outerWidth()
      )

    onSet: ->
      @collection.set @original_collection.select((child)=> @patchedFilter child)
