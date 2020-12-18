class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM DOGS")[0][0]
    end

    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map{ |dog| self.new_from_db(dog) }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.name = ?
      AND dogs.breed = ?
      LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty
      dog = Dog.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
    else
      dog = self.create(name, breed)
    end

    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map{ |dog| self.new_from_db(dog) }.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET dogs.name = ?, dogs.breed = ?
      WHERE dogs.id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
