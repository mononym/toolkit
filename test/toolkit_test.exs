defmodule ToolkitTest do
  use ExUnit.Case
  doctest Toolkit

  describe "generate_short_id" do
    test "can handle 0" do
      assert Toolkit.generate_short_id(0) == "m"
    end

    test "can handle a wide range of positive numbers including large ones" do
      result =
        0..1_000_000_000_000//10_000_000
        |> Stream.map(&Toolkit.generate_short_id/1)
        |> Stream.map(&(String.length(&1) > 0))
        |> Enum.all?(&(&1))

      assert result
    end

    test "generates unique results for the first one hundred thousand integers" do
      result =
        0..100_000
        |> Stream.map(&Toolkit.generate_short_id/1)
        |> Enum.uniq()

      assert length(result) == 100_001
    end

    test "causes a function clause error when passed a negative integer" do
      assert_raise FunctionClauseError, fn ->
        Toolkit.generate_short_id(-100)
      end
    end
  end
end
