class Program < ActiveRecord::Base
  attr_accessible :name
  attr_accessible :description
  attr_accessible :rails
  attr_accessible :revision
  attr_accessible :committed_at
end
