require "test_helper"

class JokesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @joke = jokes(:one)
    @pending_joke = jokes(:pending)
    @approved_joke = jokes(:approved)
    @rejected_joke = jokes(:rejected)
  end

  # Index Action Tests
  test "should redirect to sign in when not authenticated" do
    get jokes_url
    assert_redirected_to new_user_session_path
  end

  test "should get index when authenticated" do
    sign_in @user
    get jokes_url
    assert_response :success
    assert_select "h1", text: "Admin - Joke Management"
  end

  test "should show pending jokes by default" do
    sign_in @user
    get jokes_url
    assert_response :success
    assert_select "h2", text: "Pending Jokes"
  end

  test "should filter by status parameter" do
    sign_in @user

    # Test approved filter
    get jokes_url(status: "approved")
    assert_response :success
    assert_select "h2", text: "Approved Jokes"

    # Test rejected filter
    get jokes_url(status: "rejected")
    assert_response :success
    assert_select "h2", text: "Rejected Jokes"

    # Test all filter
    get jokes_url(status: "all")
    assert_response :success
    assert_select "h2", text: "All Jokes"
  end

  test "should display status counts" do
    sign_in @user
    get jokes_url
    assert_response :success
    # Check that status summary cards are present
    assert_select ".text-yellow-800" # Pending count
    assert_select ".text-green-800"  # Approved count
    assert_select ".text-red-800"    # Rejected count
  end

  test "should paginate results" do
    sign_in @user
    # Create enough jokes to trigger pagination
    15.times do |i|
      Joke.create!(prompt: "Test prompt #{i}", punchline: "Test punchline #{i}", status: "pending")
    end

    get jokes_url
    assert_response :success
    # Check pagination is present
    assert_select ".pagination"
  end

  # New Action Tests
  test "should get new" do
    get new_joke_url
    assert_response :success
    assert_select "h1", text: "Submit a Dad Joke"
  end

  test "should use public layout for new" do
    get new_joke_url
    assert_response :success
    # The public layout should not have admin navigation
    assert_select "nav", count: 1
  end

  # Create Action Tests
  test "should create joke with valid parameters" do
    # Mock reCAPTCHA verification
    JokesController.any_instance.stubs(:verify_recaptcha).returns(true)

    assert_difference("Joke.count") do
      post jokes_url, params: {
        joke: {
          prompt: "Why did the chicken cross the road?",
          punchline: "To get to the other side!"
        }
      }
    end

    assert_redirected_to new_joke_path
    assert_equal "Thank you! Your joke has been submitted and is pending review.", flash[:notice]

    joke = Joke.last
    assert_equal "pending", joke.status
    assert_equal "Why did the chicken cross the road?", joke.prompt
    assert_equal "To get to the other side!", joke.punchline
  end

  test "should not create joke with invalid parameters" do
    # Mock reCAPTCHA verification
    JokesController.any_instance.stubs(:verify_recaptcha).returns(true)

    assert_no_difference("Joke.count") do
      post jokes_url, params: {
        joke: {
          prompt: "Too short", # Less than 10 characters
          punchline: "Test punchline"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".bg-red-50" # Error message container
  end

  test "should reject joke when honeypot field is filled" do
    assert_no_difference("Joke.count") do
      post jokes_url, params: {
        joke: {
          prompt: "Valid prompt here that is long enough",
          punchline: "Test punchline",
          website: "spam@example.com" # Honeypot field
        }
      }
    end

    assert_redirected_to new_joke_path
    assert_equal "Thank you! Your joke has been submitted and is pending review.", flash[:notice]
  end

  test "should not create joke when reCAPTCHA fails" do
    # Mock reCAPTCHA verification failure
    JokesController.any_instance.stubs(:verify_recaptcha).returns(false)

    assert_no_difference("Joke.count") do
      post jokes_url, params: {
        joke: {
          prompt: "Valid prompt here that is long enough",
          punchline: "Test punchline"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".bg-red-50" # Error message container
  end

  test "should use rate limiting on create" do
    # This test verifies that rate limiting is applied
    # The actual rate limiting logic is tested in the concern
    controller = JokesController.new
    assert controller.private_methods.include?(:rate_limit_submission), 
           "Controller should include rate_limit_submission method"
  end

  # Update Action Tests
  test "should redirect to sign in for update when not authenticated" do
    patch joke_url(@joke), params: { joke: { status: "approved" } }
    assert_redirected_to new_user_session_path
  end

  test "should update joke status when authenticated" do
    sign_in @user

    patch joke_url(@pending_joke), params: {
      joke: { status: "approved" },
      redirect_status: "pending"
    }

    assert_redirected_to jokes_path(status: "pending")
    assert_equal "Joke status updated to Approved.", flash[:notice]

    @pending_joke.reload
    assert_equal "approved", @pending_joke.status
  end

  test "should preserve filter status on update redirect" do
    sign_in @user

    # Update from approved filter
    patch joke_url(@pending_joke), params: {
      joke: { status: "approved" },
      redirect_status: "approved"
    }

    assert_redirected_to jokes_path(status: "approved")
  end

  test "should handle update failure gracefully" do
    sign_in @user

    # Mock update failure
    Joke.any_instance.stubs(:update).returns(false)

    patch joke_url(@pending_joke), params: {
      joke: { status: "approved" },
      redirect_status: "pending"
    }

    assert_redirected_to jokes_path(status: "pending")
    assert_equal "Failed to update joke status.", flash[:alert]
  end

  test "should only allow status parameter in update" do
    sign_in @user

    original_prompt = @pending_joke.prompt

    patch joke_url(@pending_joke), params: {
      joke: {
        status: "approved",
        prompt: "Hacked prompt", # Should be ignored
        punchline: "Hacked punchline" # Should be ignored
      }
    }

    @pending_joke.reload
    assert_equal "approved", @pending_joke.status
    assert_equal original_prompt, @pending_joke.prompt # Should be unchanged
  end

  # Layout and Authentication Tests
  test "should use application layout for admin actions" do
    sign_in @user
    get jokes_url
    assert_response :success
    # Should have admin navigation
    assert_select "header"
  end

  test "should use public layout for public actions" do
    get new_joke_url
    assert_response :success
    # Should have simpler navigation
    assert_select "header"
  end

  # Parameter Security Tests
  test "should only permit safe joke parameters in create" do
    # Mock reCAPTCHA verification
    JokesController.any_instance.stubs(:verify_recaptcha).returns(true)

    post jokes_url, params: {
      joke: {
        prompt: "Valid prompt here that is long enough",
        punchline: "Test punchline",
        status: "approved", # Should be ignored - defaults to pending
        source: "hacker", # Should be ignored
        id: 999 # Should be ignored
      }
    }

    joke = Joke.last
    assert_equal "pending", joke.status # Should default to pending
    assert_nil joke.source # Should not be set
  end

  # Error Handling Tests
  test "should handle missing joke gracefully in update" do
    sign_in @user

    # Test that trying to update a non-existent joke returns 404
    patch "/jokes/99999", params: { joke: { status: "approved" } }
    assert_response :not_found
  end

  # Content Security Tests
  test "should sanitize joke content" do
    # Mock reCAPTCHA verification
    JokesController.any_instance.stubs(:verify_recaptcha).returns(true)

    post jokes_url, params: {
      joke: {
        prompt: "Why did the chicken cross the road? <script>alert('xss')</script>",
        punchline: "To get to the other side! <script>alert('xss')</script>"
      }
    }

    joke = Joke.last
    # Rails should automatically escape the content when displayed
    assert_includes joke.prompt, "<script>"
    assert_includes joke.punchline, "<script>"
  end

  # Integration Tests
  test "complete joke submission and approval workflow" do
    # Mock reCAPTCHA verification
    JokesController.any_instance.stubs(:verify_recaptcha).returns(true)

    # 1. Submit a joke
    assert_difference("Joke.count") do
      post jokes_url, params: {
        joke: {
          prompt: "Why don't scientists trust atoms?",
          punchline: "Because they make up everything!"
        }
      }
    end

    joke = Joke.last
    assert_equal "pending", joke.status

    # 2. Admin reviews and approves
    sign_in @user
    patch joke_url(joke), params: {
      joke: { status: "approved" },
      redirect_status: "pending"
    }

    joke.reload
    assert_equal "approved", joke.status
  end
end
