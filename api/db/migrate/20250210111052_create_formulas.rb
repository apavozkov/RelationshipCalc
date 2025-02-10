class CreateFormulas < ActiveRecord::Migration[8.0]
  def change
    create_table :formulas do |t|
      t.string :formula
      t.string :name

      t.timestamps
    end
  end
end
