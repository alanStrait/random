defmodule RandomWeb.UserJSON do
  # alias Random.Accounts.User

  @doc """
  Renders two, or fewer, users with points greater than random min number
  along with the timestamp for when last queried.
  """
  def index(%{data: data}) do
    timestamp =
      case data.timestamp do
        nil -> "first query"
        dt -> to_string(DateTime.to_naive(DateTime.truncate(dt, :second)))
      end

    %{data | timestamp: timestamp}
  end
end
