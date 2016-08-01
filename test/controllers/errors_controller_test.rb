require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get generic" do
    get errors_generic_url
    assert_response :success
  end

end
