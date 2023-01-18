defmodule Toolkit do
  @moduledoc """
  A collection of helper functions the author found useful across multiple projects and
  needed a common place to shove them for reuse.
  """

  @doc """
  Given a map, turns all of its keys to strings if they are not already.

  ## Examples

  iex> Toolkit.map_keys_to_strings(%{foo: :bar})
  %{"foo" => :bar}
  """
  @spec map_keys_to_strings(map) :: map
  def map_keys_to_strings(map) when is_map(map) do
    Map.new(map, fn {key, value} ->
        {to_string(key), value}
    end)
  end

  @doc """
  Given an integer value, transforms it into a short string of characters from a curated list.

  Conceived of as a way to have the advantage of short id's in a url while using UUID's as the
  DB primary id, while staying away from numbers and potential issues with slugs. However it
  would work just as well for integer primary ID's.

  The algorithm is deterministic, meaning either integer primary keys or some other method of
  ensuring repeated calls use ever increasing integers should be used. For someone using
  Postgres and UUID's, an example would be along the lines of the following call:
  ```
  %Postgrex.Result{rows: [[result]]} = Ecto.Adapters.SQL.query!(Repo, "SELECT nextval('serial')")
  ```
  That `result` could then be passed into the function and a new id would be ensured without
  having to track any additional fields.

  Don't worry too much about the id's getting too long.

  ## Examples

  iex> Toolkit.generate_short_id(1)
  "b"

  iex> Toolkit.generate_short_id(1_234_567_890)
  "vckmvqs"

  """
  @spec generate_short_id(integer) :: binary
  def generate_short_id(value) when is_integer(value) and value >= 0 do
    possible_letters = [
      "m",
      "b",
      "z",
      "f",
      "t",
      "c",
      "p",
      "j",
      "r",
      "l",
      "s",
      "d",
      "n",
      "x",
      "q",
      "w",
      "k",
      "g",
      "h",
      "v"
    ]

    generate_short_id(value, possible_letters)
  end

  @doc """
  Same as `generate_short_id/1` but allows a custom list of characters to be passed in.

  Note that smaller lists of characters will generate longer strings for any given input.

  ## Examples

  iex> Toolkit.generate_short_id(1, ["a", "e", "i", "o", "u"])
  "e"

  iex> Toolkit.generate_short_id(1_234_567_890, ["a", "e", "i", "o", "u"])
  "eaaeiaiieooaoa"

  """
  @spec generate_short_id(integer, possible_characters :: list(String.t())) :: binary
  def generate_short_id(value, possible_characters)
      when is_integer(value) and value >= 0 and is_list(possible_characters) do
    base = length(possible_characters)
    digits = calculate_digits(value, base, [])
    letters = Enum.map(digits, &Enum.at(possible_characters, &1))
    Enum.join(letters)
  end

  defp calculate_digits(remaining, base, digits) when base > remaining do
    [remaining | digits]
  end

  defp calculate_digits(remaining, base, digits) do
    more_digits = [Integer.mod(remaining, base) | digits]
    reduced_remaining = trunc(remaining / base)

    calculate_digits(reduced_remaining, base, more_digits)
  end

  @minute 60
  @hour @minute * 60
  @day @hour * 24
  @month 2_628_288
  @year @day * 365

  @doc """
  Given a number of seconds will return a string describing how far in the past it was.

  ## Examples

  iex> Toolkit.time_diff_to_string(45)
  "45 seconds ago"

  iex> Toolkit.time_diff_to_string(45_648_023_834_783)
  "1,447,489 years ago"

  iex> Toolkit.time_diff_to_string(45_648_023_834_783, "-")
  "1-447-489 years ago"
  """
  @spec time_diff_to_string(seconds :: integer, delimiter :: String.t()) :: String.t()
  def time_diff_to_string(seconds, delimiter \\ ",")
      when is_integer(seconds) and is_binary(delimiter) do
    cond do
      seconds <= @minute ->
        "#{seconds} #{maybe_plural(seconds, "second")} ago"

      seconds <= @hour ->
        diff = Integer.floor_div(seconds, @minute)
        "#{diff} #{maybe_plural(diff, "minute")} ago"

      seconds <= @day ->
        diff = Integer.floor_div(seconds, @hour)
        "#{diff} #{maybe_plural(diff, "hour")} ago"

      seconds <= @month ->
        diff = Integer.floor_div(seconds, @day)
        "#{diff} #{maybe_plural(diff, "day")} ago"

      seconds <= @year ->
        diff = Integer.floor_div(seconds, @month)
        "#{diff} #{maybe_plural(diff, "month")} ago"

      seconds ->
        diff = Integer.floor_div(seconds, @year)

        delimited_diff =
          Number.Delimit.number_to_delimited(diff, delimiter: delimiter, precision: 0)

        "#{delimited_diff} #{maybe_plural(diff, "year")} ago"
    end
  end

  defp maybe_plural(num, string) do
    if num == 1 do
      string
    else
      "#{string}s"
    end
  end
end
