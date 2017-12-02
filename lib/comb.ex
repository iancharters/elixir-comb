defmodule Comb do

  @moduledoc """
  Documentation for Comb.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Comb.hello
      :world

  """
  def main do
    fetch_change_id()
    |> fetch_trade_stream()
  end

  def fetch_trade_stream(id) do
    IO.puts "Requesting trade stream with ID: #{id}..."

    %HTTPoison.Response{body: body} = HTTPoison.get! const("trade_api_url")

    %{"stashes" => stashes} = Poison.decode!(body)

    IO.inspect(stashes, limit: :infinity)


  end

  def fetch_change_id do
    IO.puts "Requesting current change ID..."
    HTTPoison.start

    %HTTPoison.Response{body: body} = HTTPoison.get! const("change_id_url")

    %{"next_change_id" => next_change_id} = Poison.decode!(body)

    next_change_id
  end

  def const(key) do
    case key do
      "change_id_url" -> "https://api.poe.ninja/api/Data/GetStats"
      "trade_api_url" -> "http://www.pathofexile.com/api/public-stash-tabs?id="
    end
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
