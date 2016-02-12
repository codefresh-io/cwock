define ['underscore', 'backbone.marionette', 'moment', 'views/note'], (_, Marionette, moment, NoteView) ->

  class DayView extends Marionette.CompositeView

    className: 'day'

    childView: NoteView

    childViewContainer: '.notes'

    childViewOptions: ->
      parentView: @

    filter: (child, index, collection)->
      @day_date ||= @day_mom.format('l')
      moment(child.get 'taken_at').format('l') == @day_date

    constructor: (options)->
      @day_mom = moment(options.day)
      super

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

    onRender: ->
      unless @onResize
        @onResize = =>
          @$('.title').css(
            _(@$('.title-holder').offset()).extend
              width: @$('.title-holder').outerWidth()
          )
        $(window).on 'resize', @onResize
        _.defer => @onResize()

    onBeforeDestroy: ->
      $(window).off 'resize', @onResize  if @onResize
