require "application_system_test_case"

class AccountTest < ApplicationSystemTestCase
  setup { @jane = create :onboarded_user, first_name: "Jane", last_name: "Smith" }

  device_test "user can edit their account" do
    login_as(@jane, scope: :user)

    visit edit_account_user_path(@jane)
    fill_in "First Name", with: "Another"
    fill_in "Last Name", with: "Person"
    fill_in "Email", with: "someone@bullettrain.co"
    click_on "Update Profile"

    assert_text "User was successfully updated."
    assert_css 'input[value="Another"]'
    assert_css 'input[value="Person"]'
    assert_css 'input[value="someone@bullettrain.co"]'
  end

  device_test "user can edit password with valid current password" do
    login_as(@jane, scope: :user)

    visit edit_account_user_path(@jane)
    fill_in "Current Password", with: @jane.password
    fill_in "New Password", with: another_example_password
    fill_in "Confirm Password", with: another_example_password
    click_on "Update Password"
    @jane.reload

    assert_text "User was successfully updated."
    sign_out

    visit new_user_session_path
    fill_in "Email", with: @jane.email
    click_on "Next" if two_factor_authentication_enabled?
    fill_in "Your Password", with: another_example_password
    click_on "Sign In"
    assert_text "Signed in successfully."
  end

  device_test "user cannot edit password with invalid current password" do
    login_as(@jane, scope: :user)

    visit edit_account_user_path(@jane)
    fill_in "Current Password", with: "invalid"
    fill_in "New Password", with: another_example_password
    fill_in "Confirm Password", with: another_example_password
    click_on "Update Password"
    @jane.reload

    assert_text "Current password is invalid."
    sign_out

    visit new_user_session_path
    fill_in "Email", with: @jane.email
    click_on "Next" if two_factor_authentication_enabled?
    fill_in "Your Password", with: another_example_password
    click_on "Sign In"

    assert_text "Invalid Email Address or password." # TODO: I feel like password should be capitalized here?
  end
end
