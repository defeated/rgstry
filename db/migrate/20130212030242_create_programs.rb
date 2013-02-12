class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name
      t.string :description
      t.string :rails
      t.string :revision
      t.datetime :committed_at

      t.timestamps
    end
  end
end
