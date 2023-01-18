defmodule Toolkit do
  @moduledoc """
  A collection of helper functions the author found useful across multiple projects and
  needed a common place to shove them for reuse.
  """

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
end
