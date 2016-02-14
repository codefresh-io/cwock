define ['underscore', 'backbone.marionette', 'moment', 'ticker', 'views/note', 'backbone.stickit', 'jquery.scrollTo'], (_, Marionette, moment, ticker, NoteView, StickIt, ScrollTo)->

  class NoteView extends Marionette.ItemView

    className: 'note'

    events:
      'focus .taken_at .input': 'onTakenAtFocus'
      'blur .taken_at .input': 'onTakenAtBlur'
      'focus .content .input': 'onContentFocus'
      'input .content .input': 'onContentInput'
      'blur .content .input': 'onContentBlur'
      'keypress .input': 'onKeyPress'

    bindings:
      '.taken_at .value':
        observe: 'taken_at',
        onGet: 'renderFormatTakenAt'
      '.content .value':
        observe: 'content',
        onGet: 'renderFormatContent'

    template: _.template(
      '<div class="taken_at"><time class="value"></time><time class="input" contenteditable="true"></time></div>' +
      '<div class="content"><span class="value"></span><span class="input" contenteditable="true"></span></div>'
    )

    constructor: (options)->
      super
      @parentView = options.parentView

      @model.set 'content', "quid faciens"  if @isNewModel() && !@model.get('content')

    isNewModel: ->
      !@model.id
    isModelPersisted: ->
      !@isNewModel()

    isFocused: ->
      @taken_at_focused || @content_focused
    isTicking: ->
      @isNewModel() && @isFocused() && !@taken_at_focused && !@$('.content .input').text()

    renderFormatTakenAt: (taken_at)->
      mom = moment(taken_at)
      @$el.css top: "#{mom.diff(moment(mom).startOf('day'), 'hours', true) * 100/24}%"
      _(
        if @isTicking()
          mom.format('LTS')
        else
          mom.format 'LT'
      ).tap (formatted)=>
        @$('.taken_at .input').text(formatted)  unless @taken_at_focused || @taken_at_input
    renderFormatContent: (content)->
      _(content).tap (formatted)=>
        @$('.content .input').text(content)  unless @content_focused || @content_input

    onRender: ->
      unless @rendered  # XXX must be in onAttach, but couldn't get it working
        if @isNewModel()
          @listenTo ticker, 'second', @onSecond
          @listenTo ticker, 'minute', @onMinute
          _.defer => @onMinute()

          @onNavNowCallback = => @onNavNow arguments...
          $('.nav-cwock-now').on 'click', @onNavNowCallback
          _.defer @onNavNowCallback
          @content_focused = true  # NOTE setting in advance to take effect on stickit

        @onResizeCallback = => @onResize arguments...
        $(window).on 'resize', @onResizeCallback
        @onScrollCallback = => @onScroll arguments...
        $(window).on 'scroll', @onScrollCallback

      @onResize()

      @rendered = true

    onResize: ->
      @stickit()

    onSecond: (date)->
      @model.set 'taken_at', date  if @isTicking()
    onMinute: ->
      @scrollToSelf()  if @isTicking()

    onFocus: ->
      if !@was_focused
        @$el.addClass 'focused'
        @was_focused = true

    onBlur: ->
      if @was_focused
        @$el.removeClass 'focused'
        @was_focused = false

      # NOTE taken_at is a given at the moment
      if (content = @$('.content .input').text())
        @model.save content: content, taken_at: @model.get('taken_at')

      @updateNowNav false

    onContentFocus: ->
      @content_focused = true
      @onFocus()

    onContentInput: ->
      @updateNowNav false  if @isNewModel()  # NOTE there should be just one new model
      @content_input = true

    onContentBlur: ->
      @content_focused = false
      @onBlur()

    onTakenAtFocus: ->
      @$('.content .input').trigger 'focus'  # XXX temp

    onTakenAtBlur: ->

    onKeyPress: (e)->
      if e && (e.keyCode == 10 || e.keyCode == 13)  # NOTE Enter
        $(e.target).trigger 'blur'
        e.preventDefault()

    onNavNow: (e)->
      if @isNewModel()
        # XXX save if dirty instead
        @$('.content .input').trigger 'focus'
        @scrollToSelf()
      else
        $('.nav-cwock-now').off 'click', @onNavNowCallback  if @onNavNowCallback

      e.preventDefault()  if e

    onBeforeDestroy: ->
      @updateNowNav false
      $('.nav-cwock-now').off 'click', @onNavNowCallback  if @onNavNowCallback
      $(window).off 'resize', @onResizeCallback  if @onResizeCallback
      $(window).off 'scroll', @onScrollCallback  if @onScrollCallback

    updateNowNav: (is_now)->
      if is_now != @was_now
        $('.nav-cwock-now').toggleClass 'active', is_now
        @was_now = is_now

    onScroll: (e)->
      @updateNowNav false

    scrollToSelf: ->
      $.scrollTo @$el,
        offset: -$(window).height()/2
        onAfter: =>
          _.defer =>
            @updateNowNav true  if @isTicking()
