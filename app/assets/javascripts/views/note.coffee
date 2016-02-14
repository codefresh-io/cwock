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
        onGet: (taken_at)->  # XXX too much processing — when taken_at changes
          mom = moment(taken_at)
          @$el.css top: "#{mom.diff(moment(mom).startOf('day'), 'hours', true) * 100/24}%"
          _.tap(
            if @isTicking()
              @scrollToSelf()
              @updateNowNav true
              mom.format('LTS')
            else
              mom.format 'LT'
            , (formatted)=>
              @$('.taken_at .input').text(formatted)  unless @taken_at_focused || @taken_at_input
          )
      '.content .value':
        observe: 'content',
        onGet: (content)->
          @$('.content .input').text(content)  unless @content_focused || @content_input
          content

    template: _.template(
      '<div class="taken_at"><time class="value"></time><time class="input" contenteditable="true"></time></div>' +
      '<div class="content"><span class="value"></span><span class="input" contenteditable="true"></span></div>'
    )

    constructor: (options)->
      super
      @parentView = options.parentView

      @model.set 'content', "quid faciens"  if @isNewModel() && !@model.get('content')

      # XXX must be in onAttach, but couldn't get it working
      @listenTo window, 'resize', @stickit
      @listenTo ticker, 'second', @onSecond

    isNewModel: ->
      !@model.id
    isModelPersisted: ->
      !@isNewModel()

    isFocused: ->
      @taken_at_focused || @content_focused
    isTicking: ->
      @isNewModel() && @isFocused() && !@taken_at_focused && !@$('.content .input').text()


    onRender: ->
      unless @rendered
        if @isNewModel()
          @onNavNowCallback = => @onNavNow arguments...
          $('.nav-cwock-now').on 'click', @onNavNowCallback
          _.defer @onNavNowCallback
          @content_focused = true  # NOTE setting in advance to take effect on stickit

        @stickit()

      @rendered = true

    onBeforeDestroy: ->
      @updateNowNav false
      $('.nav-cwock-now').off 'click', @onNavNowCallback  if @onNavNowCallback

    onSecond: (date)->
      if @isTicking()
        @model.set 'taken_at', date
      else
        @updateNowNav false

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

    onContentFocus: ->
      @content_focused = true
      @onFocus()

    onContentInput: ->
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

    updateNowNav: (is_now)->
      if is_now != @was_now
        $('.nav-cwock-now').toggleClass 'active', is_now
        @was_now = is_now

    scrollToSelf: ->
      $.scrollTo @$el, {offset: -$(window).height()/2}
