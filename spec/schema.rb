ActiveRecord::Schema.define(:version => 20081126181722) do
  create_table :people, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
    t.belongs_to :place
  end
  
  create_table :places, :force => true do |t|
    t.column :name, :string
    t.column :location, :string 
  end
  
  create_table :things, :force => true do |t|
    t.column :name, :string
    t.column :description, :string
    t.column :created_on, :date
    t.column :updated_on, :date
  end
  
  create_table :notes, :force => true do |t|
    t.column :content, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
  
  create_table :notes_things, :force => true do |t|
    t.belongs_to :thing
    t.belongs_to :note
  end
  
  create_table :places_things, :force => true do |t|
    t.belongs_to :thing
    t.belongs_to :place
  end
end
