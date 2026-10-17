require "test_helper"
require "alchemy/seeder" # db/seeds.rb expects Alchemy's db.rake to have loaded this

# Exercises the Contact slice end to end: the seeded contactform element, the
# Alchemy::Message validations wired from config.mailer, and the redirect to the
# Thank you page on success.
class ContactFormTest < ActionDispatch::IntegrationTest
  # See PublishedPagesTest: the demo seed must persist across the process.
  self.use_transactional_tests = false

  setup do
    seed_demo_once!
    ActionMailer::Base.deliveries.clear
  end

  def contact_form_id
    Alchemy::Page.find_by!(urlname: "contact")
      .public_version.elements.find_by!(name: "contactform").id
  end

  test "the contact page renders the form with a hidden contact_form_id" do
    get "/contact"
    assert_response :success
    assert_select "form[action=?]", alchemy.messages_path
    assert_select "input[type=hidden][name=?][value=?]",
      "message[contact_form_id]", contact_form_id.to_s
  end

  test "a valid message delivers a mail and redirects to the Thank you page" do
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      post alchemy.messages_path, params: {message: {
        contact_form_id: contact_form_id,
        name: "Ada Lovelace",
        email: "ada@example.com",
        message: "Hello from the demo!"
      }}
    end

    assert_redirected_to "/contact/thank-you"
    assert_equal Alchemy.t(:success, scope: "contactform.messages"), flash[:notice]

    mail = ActionMailer::Base.deliveries.last
    assert_includes mail.body.to_s, "Hello from the demo!"
  end

  test "an invalid message re-renders the form with errors and sends nothing" do
    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      post alchemy.messages_path, params: {message: {
        contact_form_id: contact_form_id,
        name: "Ada Lovelace",
        email: "",
        message: ""
      }}
    end

    assert_response :success
    assert_select "form[action=?]", alchemy.messages_path
  end
end
