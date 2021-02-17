require "pry"

class Dog
    attr_accessor :id, :name, :breed

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end
 
    def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql =  <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
        self
    end
    
    def self.create(attr_hash)
        dog = self.new(name: attr_hash[:name], breed: attr_hash[:breed])
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])  
    end

    def self.find_by_id (id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        self.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

        result = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
        if !result.empty? 
            dog = self.new(id: result[0], name: result[1], breed: result[2])
        else
            dog = self.create(hash)
        end
        dog
    end

    def self.find_by_name (name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        result = DB[:conn].execute(sql, name)[0]
        self.new(id: result[0], name: result[1], breed: result[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed= ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end