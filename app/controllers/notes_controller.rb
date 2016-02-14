class NotesController < ApplicationController
  respond_to :html, :only => :index
  respond_to :json

  def index
    respond_with Note.all
  end

  def create
    respond_with Note.create(note_params)
  end

  def update
    respond_with Note.find(params.delete :id).update(note_params)
  end

  private

  def note_params
    params.permit(:content, :taken_at)
  end
end
