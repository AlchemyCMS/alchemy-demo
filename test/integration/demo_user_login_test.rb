require "test_helper"

class DemoUserLoginTest < ActionDispatch::IntegrationTest
  setup do
    Alchemy::User.create!(
      login: "demo-test",
      email: "demo-test@example.com",
      password: "s3cr3t-demo",
      password_confirmation: "s3cr3t-demo",
      alchemy_roles: "demo"
    )
  end

  test "a demo user lands on the admin dashboard after logging in" do
    post alchemy.admin_login_path, params: {user: {login: "demo-test", password: "s3cr3t-demo"}}
    assert_redirected_to alchemy.admin_dashboard_path

    follow_redirect!
    assert_response :success
  end
end
