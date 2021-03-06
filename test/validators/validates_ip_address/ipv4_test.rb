require "test_helper"

class Ipv4Test < Minitest::Test
  let(:user) { User.new }

  test "is valid" do
    User.validates_ip_address :url, only: :v4
    user.url = "192.168.1.2"

    assert user.valid?
  end

  test "is invalid" do
    User.validates_ip_address :url, only: :v4
    user.url = "FE80:0000:0000:0000:0202:B3FF:FE1E:8329"

    refute user.valid?
    assert_includes user.errors[:url], "is not a valid IPv4 address"
  end
end
