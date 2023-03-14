defmodule Random.Accounts.Boundary.DataContainer do
  use GenServer
  alias Random.Accounts
  alias Random.Repo

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
    process_send_after(60_000)
    ## initialize all points with random integer between 0 and 100
    # update_all_points()
    ## assign min_number with random integer between 0 and 100

    {:noreply, %{state | min_number: 15, last_queried: DateTime.utc_now()}}
  end

  @impl true
  def handle_info(:update_points, %{min_number: min_number, last_queried: last_queried} = state) do
    IO.puts("\thandle_info:update_points, min_number #{min_number} last_queried #{last_queried}")
    process_send_after(60_000)

    update_all_points()

    {:noreply, %{state | min_number: rem(min_number + 5, 100), last_queried: DateTime.utc_now()}}
  end

  @impl true
  def terminate(reason, %{min_number: min_number, last_queried: last_queried} = state) do
    IO.puts("\tterminate reason #{reason} min_number #{min_number} last_queried #{last_queried}")

    state
  end

  ## Supporting
  defp update_all_points() do
    begin_time = System.monotonic_time(:millisecond)

    now = DateTime.to_naive(DateTime.truncate(DateTime.utc_now(), :second))

    # user_update_list =
    1..100
    |> Enum.each(fn outer_value ->
      (outer_value * 10_000 - 9999)..(outer_value * 10_000)
      |> Enum.into([], fn inner_value ->
        %{id: inner_value, points: random_number(101), updated_at: now, inserted_at: now}
      end)
      |> update_all_points()
      # |> IO.inspect(label: "\nUPDATE_ALL_POINTS\n")
    end)

    fin_time = System.monotonic_time(:millisecond)
    IO.puts("\tupdate_all_points time: #{fin_time - begin_time}")
    :ok
  end

  defp update_all_points(user_update_list) do
    Repo.transaction(fn ->
      Repo.insert_all(
        "users",
        user_update_list,
        on_conflict: {:replace, [:points, :updated_at]},
        conflict_target: :id
      )
    end)
    |> IO.inspect(label: "\nUPDATE_ALL_POIntS RESULT\t")
  end

  defp random_number(max_val) do
    :rand.uniform(max_val) - 1
  end

  defp process_send_after(ms) do
    Process.send_after(__MODULE__, :update_points, ms)
  end
end
