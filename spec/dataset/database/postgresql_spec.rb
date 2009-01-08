require File.expand_path(File.dirname(__FILE__)) + '/../../spec_helper'

# PostgreSQL-specific specs.  Assumes the existence of a database
# in a local PostgreSQL with this access configuration:
#   adapter: postgresql
#   database: dataset_test
#   username: dataset_test
#   password: dataset_test

if ENV['TEST_POSTGRESQL']
  describe Dataset::Database::Postgresql do
    before(:all) do
      ActiveRecord::Base.silence do
        ActiveRecord::Base.configurations = {'test' => {
          'adapter' => 'postgresql',
          'database' => 'dataset_test',
          'username' => 'dataset_test',
          'password' => 'dataset_test'
        }}
        ActiveRecord::Base.establish_connection 'test'
        
        drop_fks
        load "#{SPEC_ROOT}/schema.rb"
      end
    end
    
    def drop_fks
      ActiveRecord::Base.connection.select_all(
        "SELECT table_name, constraint_name FROM information_schema.table_constraints WHERE constraint_type='FOREIGN KEY'"
      ).each do |row|
        ActiveRecord::Base.connection.execute("ALTER TABLE #{row['table_name']} DROP CONSTRAINT #{row['constraint_name']}")
      end
    end
    
    before do
      @adapter = Dataset::Database::Postgresql.new(
        ActiveRecord::Base.configurations['test'], 
        "#{SPEC_ROOT}/tmp"
      )
    end
    
    describe "table order" do
      FKS = [
        %w(people place_id places),
        %w(places_things place_id places),
        %w(places_things thing_id things),
        %w(notes_things  note_id  notes),
        %w(notes_things  thing_id things)
      ]
      
      before(:all) do
        FKS.each do |child_table, key, parent_table|
          ActiveRecord::Base.connection.execute <<-SQL
            ALTER TABLE #{child_table} 
              ADD CONSTRAINT fk_#{child_table}_#{parent_table} 
                  FOREIGN KEY (#{key}) REFERENCES #{parent_table}
          SQL
        end
      end
      
      it "orders single links correctly" do
        @adapter.clear_order.should have_partial_order("people", "places")
      end
      
      it "orders cascaded links correctly" do
        @adapter.clear_order.should have_partial_order("people", "things")
      end
    end
  end
end