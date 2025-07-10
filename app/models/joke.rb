# == Schema Information
#
# Table name: jokes
#
#  id         :integer          not null, primary key
#  punchline  :string
#  prompt     :string
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
  enum :status, pending: "pending", approved: "approved", rejected: "rejected"

  validates :prompt, presence: true, length: { minimum: 10, maximum: 500 }
  validates :punchline, length: { maximum: 500 }
  validates :status, presence: true
end
