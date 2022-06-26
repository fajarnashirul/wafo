class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :firstname, null: false
      t.string :lastname
      t.string :phone_number, null: false

      t.timestamps
    end
  end
end
