defmodule Comb do
  @change_id_url "https://api.poe.ninja/api/Data/GetStats"
  @trade_api_url "http://www.pathofexile.com/api/public-stash-tabs?id="
  @moduledoc """
  Documentation for Comb.
  """

  @doc """
  Application starting point.

  ## Examples

      iex> Comb.main
      Requesting current change ID...

  """
  def main do
    HTTPotion.start()

    fetch_initial_change_id()
    |> fetch_trade_stream()
  end

  def scan(stashes) do
    count = Enum.count(stashes)
    IO.puts "Stashes updated: #{count}"

    Enum.each(stashes, fn(stash) ->
      %{
        "lastCharacterName" => lastCharacterName,
        "stashType" => stashType,
        "stash" => stash,
        "items" => items,
      } = stash

      IO.inspect(lastCharacterName)

      if lastCharacterName != nil && String.downcase(lastCharacterName) == "ifukcforgodexile" do
        IO.inspect items
      end

    end)

    if count < 5 do
      :timer.sleep(1150)
    end
  end

  def fetch_trade_stream(id) do
    { _ , {h, m, s} } = :calendar.local_time

    message("[#{h}:#{m}:#{s}] Requesting trade stream with ID: #{id}...")

    %{"next_change_id" => next_change_id, "stashes" => stashes} =
      HTTPotion.get(@trade_api_url <> id, [timeout: 50_000]).body()
      |> Poison.decode!

    scan(stashes)

    fetch_trade_stream(next_change_id)
  end

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
