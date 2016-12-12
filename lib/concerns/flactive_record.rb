module FlactiveRecord

  class Base

    def self.table_name
      self.to_s.downcase + 's'
    end

    def self.define_attributes
      self.column_names.each do |column_name|
        # 'message'
        attr_accessor(column_name)
      end
    end

    def self.column_names
      table_info = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
      table_info.collect do |column_info|
        column_info["name"]
      end.compact
    end

    def self.columns_for_insert
      column_names.reject {|name| name == "id" }
    end

    def self.column_names_for_insert
      self.columns_for_insert.join(", ")
    end

    def initialize(options={})
      # @message = options['message']
      # @username = options['username']
      # @id = options['id']
      options.each do |attribute, value|
        # attribute 'message', value 'Great coffee'
        self.send("#{attribute}=", value)
      end
    end

    def self.all
      # find all the rows in the database
      sql = <<-SQL
      SELECT *
      FROM #{self.table_name};
      SQL
      results = DB[:conn].execute(sql)
      results.map do |result|
        attributes = {}
        result.each do |attribute, value|
          unless attribute.is_a?(Integer)
            attributes[attribute] = value
          end
        end
        self.new(attributes)
      end
    end

    def values_for_insert
      self.class.columns_for_insert.map do |column|
        "'#{self.send(column)}'"
      end.join(", ")
    end

    def save
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (#{self.class.column_names_for_insert})
        VALUES (#{self.values_for_insert})
      SQL

      DB[:conn].execute(sql)
      id_sql = <<-SQL
      SELECT id FROM #{self.class.table_name}
      ORDER BY id DESC
      LIMIT 1
      SQL

      id_result = DB[:conn].execute(id_sql).first
      @id = id_result["id"]
      self
    end

  end

end
