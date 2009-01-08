module Dataset
  module Database # :nodoc:
    
    # The interface to a PostgreSQL database, this will capture by creating a dump
    # file and restore by loading one of the same.
    #
    class Postgresql < Base
      def initialize(database_spec, storage_path)
        @database = database_spec[:database]
        @username = database_spec[:username]
        @password = database_spec[:password]
        @storage_path = storage_path
        FileUtils.mkdir_p(@storage_path)
        @orderer = build_orderer
      end
      
      def capture(datasets)
        return if datasets.nil? || datasets.empty?
        `pg_dump -c #{@database} > #{storage_path(datasets)}`
      end
      
      def restore(datasets)
        store = storage_path(datasets)
        if File.file?(store)
          `psql -U #{@username} -p #{@password} -e #{@database} < #{store}`
          true
        end
      end
      
      def storage_path(datasets)
        "#{@storage_path}/#{datasets.collect {|c| c.__id__}.join('_')}.sql"
      end
      
      def clear_order
        @clear_order ||= @orderer.deletion_order
      end
      
      private
      
      def build_orderer
        orderer = TableOrderer.new
        tables = ActiveRecord::Base.connection.tables
        tables.each { |t| orderer.add_table(t) }
        rows = ActiveRecord::Base.connection.select_all(<<-SQL)
          SELECT fct.table_name AS child, uct.table_name AS parent
            FROM information_schema.table_constraints fct
            INNER JOIN information_schema.referential_constraints rc
              ON fct.constraint_name = rc.constraint_name
            INNER JOIN information_schema.table_constraints uct
              ON rc.unique_constraint_name = uct.constraint_name
        SQL
        rows.each do |row|
          orderer.link row['parent'], row['child']
        end
        
        orderer
      end
    end
  end
end