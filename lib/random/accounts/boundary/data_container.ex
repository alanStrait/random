defmodule Random.Accounts.Boundary.DataContainer do
  use GenServer

  defstruct min_number: nil,
            last_queried: nil

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  ## Client API

  ## Server Callbacks

  @impl true
  def init(_args) do
    {:ok, %__MODULE__{}, {:continue, :initialize_points}}
  end

  @impl true
  def handle_continue(:initialize_points, %{min_number: _min_number, last_queried: _last_queried} = state) do
    ## set timer for 60 seconds to update points
    Process.send_after(__MODULE__, :update_points, 5_000)
    ## initialize all points with random integer between 0 and 100
    ## assign min_number with random integer between 0 and 100

    {:noreply, %{state | min_number: 15, last_queried: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:update_points, %{min_number: min_number, last_queried: last_queried} = state) do
    IO.puts("\thandle_info:update_points, min_number #{min_number} last_queried #{last_queried}")
    Process.send_after(__MODULE__, :update_points, 5_000)

    {:noreply, %{state | min_number: rem(min_number + 5, 100), last_queried: DateTime.utc_now()}}
  end

  @impl true
  def terminate(reason, %{min_number: min_number, last_queried: last_queried} = state) do
    IO.puts("\tterminate reason #{reason} min_number #{min_number} last_queried #{last_queried}")

    state
  end
end
