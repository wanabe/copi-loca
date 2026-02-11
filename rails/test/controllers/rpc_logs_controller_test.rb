require "test_helper"

class RpcLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rpc_log = rpc_logs(:one)
  end

  test "should get index" do
    get rpc_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_rpc_log_url
    assert_response :success
  end

  test "should create rpc_log" do
    assert_difference("RpcLog.count") do
      post rpc_logs_url, params: { rpc_log: { direction: @rpc_log.direction, message: @rpc_log.message, session_id: @rpc_log.session_id } }
    end

    assert_redirected_to rpc_log_url(RpcLog.last)
  end

  test "should show rpc_log" do
    get rpc_log_url(@rpc_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_rpc_log_url(@rpc_log)
    assert_response :success
  end

  test "should update rpc_log" do
    patch rpc_log_url(@rpc_log), params: { rpc_log: { direction: @rpc_log.direction, message: @rpc_log.message, session_id: @rpc_log.session_id } }
    assert_redirected_to rpc_log_url(@rpc_log)
  end

  test "should destroy rpc_log" do
    assert_difference("RpcLog.count", -1) do
      delete rpc_log_url(@rpc_log)
    end

    assert_redirected_to rpc_logs_url
  end
end
