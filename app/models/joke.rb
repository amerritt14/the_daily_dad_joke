# == Schema Information
#
# Table name: jokes
#
#  id         :integer          not null, primary key
#  answer     :string
#  question   :string
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  source_id  :string
#
class Joke < ApplicationRecord
  SOURCE_URL = {
    icanhazdadjoke: "https://icanhazdadjoke.com/"
  }.freeze

  has_one :post, dependent: :destroy

  enum :source, icanhazdadjoke: "icanhazdadjoke"
end
