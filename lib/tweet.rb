class Tweet < FlactiveRecord::Base
  # attr_accessor :message, :username, :id


  define_attributes

  def update
    sql = <<-SQL
    UPDATE tweets SET username = ?, message = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.username, self.message, self.id)
    self
  end

end
