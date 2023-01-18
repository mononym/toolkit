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

  describe "time_diff_to_string" do
    test "causes a function clause error when passed a negative integer" do
      assert_raise FunctionClauseError, fn ->
        Toolkit.generate_short_id(-100)
      end
    end

    test "properly plurals" do
      assert Toolkit.time_diff_to_string(0) == "0 seconds ago"
      assert Toolkit.time_diff_to_string(1) == "1 second ago"
      assert Toolkit.time_diff_to_string(2) == "2 seconds ago"
    end

    test "can handle seconds" do
      assert Toolkit.time_diff_to_string(30) == "30 seconds ago"
    end

    test "can handle minutes" do
      assert Toolkit.time_diff_to_string(60 * 30) == "30 minutes ago"
    end

    test "can handle hours" do
      assert Toolkit.time_diff_to_string(60 * 30 * 18) == "9 hours ago"
    end

    test "can handle days" do
      assert Toolkit.time_diff_to_string(60 * 60 * 24 * 7) == "7 days ago"
    end

    test "can handle months" do
      assert Toolkit.time_diff_to_string(60 * 60 * 24 * 45) == "1 month ago"
    end

    test "can handle years" do
      assert Toolkit.time_diff_to_string(60 * 60 * 24 * 500) == "1 year ago"
    end
  end
end
