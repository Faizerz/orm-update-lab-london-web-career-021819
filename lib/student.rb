require_relative "../config/environment.rb"

class Student
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if @id
      DB[:conn].execute("UPDATE students SET name = (?), grade = (?) WHERE id = (?)", @name, @grade, @id)
    else
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?)", @name, @grade)
      @id = DB[:conn].execute("SELECT id FROM students WHERE name = ? and grade = ?", @name, @grade).flatten.first
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?)", new_student.name, new_student.grade)
  end

  def self.new_from_db(row)
    id, name, grade = row
    self.new(name, grade, id)
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM students WHERE name = ? LIMIT 1",name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", self.name, self.grade, self.id)
  end


end
