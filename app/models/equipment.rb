class Equipment < ActiveRecord::Base
  belongs_to :station

  def routes
    train_no.split('').sort
  end
end
