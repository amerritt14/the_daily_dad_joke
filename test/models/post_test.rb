# == Schema Information
#
# Table name: posts
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  beehiiv_post_id :string
#  joke_id         :integer          not null
#
# Indexes
#
#  index_posts_on_joke_id  (joke_id)
#
# Foreign Keys
#
#  joke_id  (joke_id => jokes.id)
#
require "test_helper"

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
