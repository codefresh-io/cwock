define ['underscore', 'backbone.marionette', 'moment', 'ticker', 'views/note', 'backbone.stickit', 'jquery.scrollTo'], (_, Marionette, moment, ticker, NoteView, StickIt, ScrollTo) ->

  class NoteView extends Marionette.ItemView

    className: 'note'

    bindings:
      '.taken_at .value':
        observe: 'taken_at',
        onGet: (taken_at)->  # XXX too much processing — when taken_at changes
          mom = moment(taken_at)
          @$el.css top: "#{mom.diff(moment(mom).startOf('day'), 'hours', true) * 100/24}%"
          if @ticking
            $.scrollTo @$el, {offset: -$(window).height()/2}
            mom.format('LTS')
          else
            mom.format 'LT'
      '.content .value': 'content'

    template: _.template(
      '<div class="taken_at"><time class="value"></time></div>' +
      '<div class="content"><span class="value" contenteditable="true">Quid facis?</div></div>'
    )

    constructor: (options)->
      super

      @parentView = options.parentView

      @ticking = @isNewModel()

    isNewModel: ->
      !@model.id
    isModelPersisted: ->
      !@isNewModel()

    onRender: ->
      unless @onSecondTickCallback
        @onSecondTickCallback = (date)=>
          @model.set 'taken_at', date.getTime()  if @ticking
          @$el.addClass 'focused', @focused || @ticking
        ticker.on 'second', @onSecondTickCallback
      unless @onResize
        @onResize = => @stickit()
        $(window).on 'resize', @onResize
      @stickit()

    onBeforeDestroy: ->
      $(window).off 'resize', @onResize
      ticker.off 'second', @onSecondTickCallback  if @onSecondTickCallback
