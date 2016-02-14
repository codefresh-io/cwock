define ['backbone', 'models/note'], (Backbone, Note)->
  class NoteCollection extends Backbone.Collection
    model: Note
    url: 'notes'
