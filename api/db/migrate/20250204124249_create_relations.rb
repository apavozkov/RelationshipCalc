class CreateRelations < ActiveRecord::Migration[8.0]
  def change
    create_table :relations do |t|
      t.string :relative
      t.string :dependant
      t.string :relation

      t.timestamps
    end
  end
end
