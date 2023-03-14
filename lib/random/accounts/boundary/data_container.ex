defmodule Random.Accounts.Boundary.DataContainer do
  use GenServer
  alias Random.{Accounts, Repo}
  require Logger

  defstruct min_number: 0,
            last_queried: nil

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  ## Client API
  def users_with_points_gt_min_number() do
    GenServer.call(__MODULE__, :users_with_points_gt_min_number)
  end

  ## Server Callbacks

  @impl true
  def init(_args) do
    {:ok, %__MODULE__{}, {:continue, :initialize_points}}
  end

  @impl true
  def handle_continue(:initialize_points, state) do
    ## set timer for 60 seconds to update points
    process_send_after(60_000)
    ## compute user id blocks and store in ETS

    {:noreply, state}
  end

  @impl true
  def handle_call(:users_with_points_gt_min_number, _from, %{last_queried: last_queried} = state) do
    [u1|[u2|[]]] = Accounts.users_with_points_gt_min_number(state.min_number)

    {
      :reply,
      %{users: [%{id: u1.id, points: u1.points}, %{id: u2.id, points: u2.points}], timestamp: last_queried},
      %{state | last_queried: DateTime.utc_now()}
    }
  end

  @impl true
  def handle_info(:update_points, state) do
    process_send_after(60_000)

    update_all_points()

    {:noreply, %{state | min_number: random_number(101)}}
  end

  @impl true
  def terminate(reason, %{min_number: min_number, last_queried: last_queried} = state) do
    Logger.info("\tterminate reason #{reason} min_number #{min_number} last_queried #{last_queried}")

    state
  end

  ## Supporting
  defp update_all_points() do
    begin_time = System.monotonic_time(:millisecond)

    now = DateTime.to_naive(DateTime.truncate(DateTime.utc_now(), :second))

    1..100
    |> Enum.each(fn outer_value ->
      (outer_value * 10_000 - 9999)..(outer_value * 10_000)
      |> Enum.into([], fn inner_value ->
        %{id: inner_value, points: random_number(101), updated_at: now, inserted_at: now}
      end)
      |> update_all_points()
    end)

    fin_time = System.monotonic_time(:millisecond)
    Logger.info("\tupdate_all_points time: #{fin_time - begin_time}")
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
  end

  defp random_number(max_val) do
    :rand.uniform(max_val) - 1
  end

  defp process_send_after(ms) do
    Process.send_after(__MODULE__, :update_points, ms)
  end
end
