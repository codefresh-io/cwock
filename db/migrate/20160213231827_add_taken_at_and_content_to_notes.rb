class AddTakenAtAndContentToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :taken_at, :datetime
    add_column :notes, :content, :string
  end
end
