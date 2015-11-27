class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :gender
      t.integer :age
      t.integer :status
      t.boolean :present
      t.float :pref_temperature
      t.integer :credit_temperature
      t.float :pref_humidity
      t.integer :credit_humidity
      t.boolean :pref_light0
      t.integer :credit_light0
      t.boolean :pref_light1
      t.integer :credit_light1
      t.boolean :pref_light2
      t.integer :credit_light2
      t.boolean :pref_light3
      t.integer :credit_light3
      t.datetime :moment
      t.timestamps null: false
    end
  end
end
