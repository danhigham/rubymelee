require 'sequel'
require 'uuidtools'

class Melee < Sequel::Model
  def before_create
    self.guid ||= UUIDTools::UUID.random_create.to_s
    super
  end
end