defmodule Comb do
  @change_id_url "https://api.poe.ninja/api/Data/GetStats"
  @trade_api_url "http://www.pathofexile.com/api/public-stash-tabs?id="

  @moduledoc """
  Documentation for Comb.
  """

  @doc """
  Application starting point.
  """

  def main do
    HTTPotion.start()

    fetch_initial_change_id()
    |> fetch_trade_stream()
  end

  @doc """
  Scan takes in `stashes` as input, and then splits them up into distinct
  objects as `stash`.  This is where logic is run to see if items we're looking
  for appear in the trade stream.
  """

  def scan(stashes) do
    count = Enum.count(stashes)
    IO.puts "Stashes updated: #{count}"

    Enum.each(stashes, fn(%{
      "lastCharacterName" => lastCharacterName,
      "stashType" => stashType,
      "stash" => stash,
      "items" => items,
    }) ->
      if lastCharacterName != nil && String.downcase(lastCharacterName) == "ifukcforgodexile" do
        alert("FOUND")
      end

      Enum.each(items, fn
        %{"name" => ""} ->
          nil
        %{"name" => name, "note" => note} ->
          case note_valid?(List.first(String.split note, " ")) do
            true ->
              item_name = String.split(name, ">")
                          |> List.last
              item_price = sale_info(String.split note, " ")
              IO.inspect {lastCharacterName, item_name, item_price}
            false ->
              nil
          end
        _ ->
          nil
      end)
    end)

    if count < 5 do
      :timer.sleep(1150)
    end
  end

  @doc """
    To doc.
  """
  def sale_info([type, value, currency]) do
    {type, value, currency}
  end

  @doc """
  Checks if the note attached to an item is a valid sale type `~b/o` or
  `~price`

  ## Examples

        iex> Comb.note_valid?("~b/o 1 chaos")
        true
        iex> Comb.note_valid?("~price 1 chaos")
        true
        iex> Comb.note_valid?("some other message")
        false

  """
  def note_valid?(note) do
    # TODO: add logic to check if ~b/o or ~price are at the begining of string.
    String.contains?(note, "~b/o") or String.contains?(note, "~price")
  end

  @doc """
  Takes `next_change_id` as param `id` and fetches the next payload in the
  stream.  It runs `scan` on the payload which is what actually checks the
  object for items we're looking for.
  """

  def fetch_trade_stream(id) do
    { _ , {h, m, s} } = :calendar.local_time

    message("[#{h}:#{m}:#{s}] Requesting trade stream with ID: #{id}...")

    %{"next_change_id" => next_change_id, "stashes" => stashes} =
      HTTPotion.get(@trade_api_url <> id, [timeout: 50_000]).body()
      |> Poison.decode!

    scan(stashes)

    fetch_trade_stream(next_change_id)
  end

  @doc """
  We use `fetch_initial_change_id` to grab a `next_change_id` near the head of
  the Path of Exile trade API stream.  We query the `@change_id_url` API for it.
  If we did not grab this, we would have to start at the very beginning of the
  stream, which would result in hundreds of GB in payloads we would have to take
  in.
  """

  def fetch_initial_change_id do
    IO.puts "Requesting initial change ID..."
    HTTPoison.start

    %HTTPoison.Response{body: body} = HTTPoison.get! @change_id_url

    %{"next_change_id" => next_change_id} = Poison.decode!(body)

    next_change_id
  end

  def alert(message) do
    delimeter()
    IO.puts(message)
    delimeter()
  end

  def message(message) do
    IO.puts IO.ANSI.green <> message <> IO.ANSI.reset
  end

  def delimeter do
    IO.puts IO.ANSI.red <>
     "********************************************************************************" <>
    IO.ANSI.reset
  end
end
