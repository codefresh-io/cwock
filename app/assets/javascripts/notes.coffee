
class Note extends Backbone.Model
  initialize: ->
    @set 'created_at', Date.now()
    @set 'content', ''

class NoteView extends Marionette.ItemView

  className: 'note'

  bindings:
    '.created_at .value':
      observe: 'created_at',
      onGet: (created_at)->  # XXX too much
        mom = moment(created_at)
        @$el.css top: "#{(mom.hour() + 1 + mom.minutes()/60) * (@parent.$('.title').height())}px"
        $.scrollTo @$el, {offset: -$(window).height()/2}  if @focused
        mom.format('LTS')
    '.content .value': 'content'

  template: _.template(
    '<div class="created_at"><time class="value"></time></div>' +
    '<div class="content"><span class="value" contenteditable="true"></big></div>'
  )

  initialize: (options)->
    @parent = options.parent
    @focused = !@model.id  # NOTE we probably want to enter a new note here

  onRender: ->
    @stickit()
    @$el.addClass 'focused', !!@focused

class DayView extends Marionette.CompositeView

  childView: NoteView

  childViewContainer: '.notes'

  initialize: (options)->
    @day = options.day
    super

  childViewOptions: ->
    parent: @

  template: _.template(
    '<div class="title holder"></div><div class="title"><div class="dow"><%= dow %></div><div class="date"><%= date %></div><div class="ref"><%= ref %></div></div>' +
    '<div class="time-scale">' + ("<div class='hour'>#{moment(new Date).startOf('day').add(h, 'hours').format('LT')}</div>" for h in [0..23]).join('') + '</div>' +
    '<div class="notes"></div>'
  )

  serializeData: ->
    dow: moment(@day).format('dddd')
    date: moment(@day).format('ll')
    ref: /^(\D+)\D/.exec(moment(@day).calendar(new Date))[0]

  onRender: ->
    @$('.title').css(
      _(@$('.title.holder').offset()).extend
        width: @$('.title.holder').width()
    )

# boot

moment.locale window.navigator.language

window.notes = notes = new Backbone.Collection

today_view = new DayView(
  day: new Date  # XXX en
  collection: notes  # XXX filter for today
  el: '#cwock'
).render()

current_note = new Note
notes.add current_note

ticker_time = ->
  current_note.set 'created_at', Date.now()
  setTimeout ticker_time, 1000
ticker_time()
