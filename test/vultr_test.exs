defmodule VultrTest do
  use ExUnit.Case

  test "requests work" do
    assert {:ok, _} = Vultr.app_list()
  end
end
