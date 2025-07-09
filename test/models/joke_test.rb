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
require "test_helper"

class JokeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
