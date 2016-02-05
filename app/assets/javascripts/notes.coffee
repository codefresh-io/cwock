Note = Backbone.Model.extend(
  initialize: ->
    @set 'created_at', Date.now()
)

NoteView = Marionette.ItemView.extend(
  onRender: -> @stickit()

  bindings:
    '.created_at .value':
      observe: 'created_at',
      onGet: (created_at)-> moment(created_at).format('LTS')

  template: _.template(
    '<div class="created_at"><big><time class="value"><%= created_at %></time></big>'
  )

)

DayView = Marionette.CollectionView.extend(
  childView: NoteView
)

# boot

moment.locale window.navigator.language

notes = new (Backbone.Collection)
current_note = new Note
notes.add current_note

ticker_time = ->
  current_note.set 'created_at', Date.now()
  setTimeout ticker_time, 1000
ticker_time()

new DayView(
  collection: notes
  el: '#cwock'
).render()
