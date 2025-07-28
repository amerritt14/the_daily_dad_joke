class AdminNotificationMailer < ApplicationMailer
  default from: 'noreply@thedailydadjoke.com'

  def pending_jokes_summary(user)
    @user = user
    @pending_count = Joke.pending.count
    @approved_count = Joke.approved.count
    @rejected_count = Joke.rejected.count
    @total_count = Joke.count
    @recent_pending_jokes = Joke.pending.order(created_at: :desc).limit(5)

    mail(
      to: user.email,
      subject: "Daily Dad Joke Admin Summary - #{@pending_count} Jokes Pending Review"
    )
  end
end
