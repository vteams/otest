class CreateRecurringProfileLineItems < ActiveRecord::Migration
  def change
    create_table :recurring_profile_line_items do |t|
      t.integer :invoice_id
      t.integer :item_id
      t.string :item_name
      t.string :item_description
      t.decimal :item_unit_cost
      t.decimal :item_quantity
      t.integer :tax_1
      t.integer :tax_2

      t.timestamps
    end
  end
end
