defmodule FlowdockTest do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    url = "http://www.pathofexile.com/api/public-stash-tabs?id=110455867-115865855-108687012-125276864-117095269"
    {:ok, HTTPoison.get!(url, %{"Accept" => "application/json"}, [stream_to: self(), recv_timeout: :infinity])}
  end

  def handle_info(msg, state) do
    IO.inspect {:handle_info, Poison.decode!(msg), limit: :infinity}
    {:noreply, state}
  end

end
