defmodule Comb.Session do
  defstruct
  player: %{
    lastCharacterName: nil,
    stash: nil,
    items: nil
  }
end
