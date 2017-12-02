defmodule Mix.Tasks.Go do
  use Mix.Task

  def run(_) do
    Comb.main()
  end
end
