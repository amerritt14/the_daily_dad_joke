class Joke < ApplicationRecord
  has_one :post, dependent: :destroy
end
