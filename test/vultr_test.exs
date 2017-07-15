defmodule VultrTest do
  use ExUnit.Case

  test "requests work" do
  	response = Vultr.app_list()
    assert response.status === 200
  end
end
