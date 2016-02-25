require 'rails_helper'

RSpec.describe NotesController, type: :controller do

  render_views

  describe 'GET index' do

    it "should be OK" do
      get :index
      expect(response).to be_success
    end

  end

end
