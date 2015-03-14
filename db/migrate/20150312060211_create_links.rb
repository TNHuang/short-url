class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
    	t.string :in_url, null: false
    	t.text :out_url, null: false
    	t.integer :http_status, default: 301, null: false

    	t.timestamps
    end

    add_index :links, [:out_url, :in_url], unique: true
    add_index :links, :out_url, unique: true
    add_index :links, :in_url, unique: true
  end
end
