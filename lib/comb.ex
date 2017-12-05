 defmodule Comb do
  @change_id_url "https://api.poe.ninja/api/Data/GetStats"
  @trade_api_url "http://www.pathofexile.com/api/public-stash-tabs?id="
  @filter [
    %{
      :name => "Voll's Devotion",
      :price => 5,
      :currency => 'chaos',
      :modifiers => {},
    },
    %{
      :name => "Nomic's Storm",
      :price => 2,
      :currency => 'exa',
      :modifiers => {}
    },
    %{
      :name => "Ornament of the East",
      :price => 9,
      :currency => 'chaos',
      :modifiers => {}
    },
  ]

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
      "stash" => stash,
      "items" => items,
    }) ->

      Enum.each(items, fn
        %{"name" => ""} ->
          nil
        %{"name" => name, "note" => note, "w" => w, "h" => h, "league" => league, "typeLine" => item_type} ->
          case note_valid?(List.first(String.split note, " ")) do
            true ->
              item_name = String.split(name, ">")
                          |> List.last

              [_, price, currency] = String.split(note, " ")

              apply_filter({item_name, {price, currency}, item_type, w, h, lastCharacterName, stash, league}, @filter)
            false ->
              nil
          end
        _ ->
          nil
      end)
    end)

    :timer.sleep(500)
  end

  def apply_filter({name, {price, currency}, type, w, h, player, stash, league} = params, filters) do
    Enum.each(filters, fn %{:name => fname, :price => fprice, :currency => fcurrency, :modifiers => fmodifiers} ->
      if String.downcase(name) == String.downcase(fname) do
        send_tell(params)
        alert("#{name} | #{price} | #{fcurrency}")
        {fname, fprice, fcurrency, fmodifiers}
      end
    end)
  end

  @doc """
    To doc.
  """
  def sale_info([type, value, currency | _]) do
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
        iex> Comb.note_valid?("some ~price other ~b/o message")
        false

  """
  def note_valid?(note) do
    # TODO: make sure these mongs don't do "~price FREE" or similar
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

  def send_tell({item_name, {item_price, currency}, item_type, w, h, player, stash, league}) do
    #@MinashaPlease Hi, I would like to buy your Kaom's Heart Glorious Plate listed for 200 alteration in Standard (stash tab "$$"; position: left 5, top 1)
    message = "@#{player} Hi, I would like to buy your #{item_name} #{item_type} listed for #{item_price} #{currency} in #{league} (stash tab \"#{stash}\"; position: left #{w}, top #{h})"
    IO.puts IO.ANSI.yellow <> message <> IO.ANSI.reset
  end

  # def find_player do
  #   if lastCharacterName != nil && String.downcase(lastCharacterName) == "ifukcforgodexile" do
  #     alert("FOUND")
  #   end
  # end

  def delimeter do
    IO.puts IO.ANSI.red <>
     "********************************************************************************" <>
    IO.ANSI.reset
  end
end
