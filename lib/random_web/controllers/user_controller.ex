defmodule RandomWeb.UserController do
  use RandomWeb, :controller

  alias Random.Accounts.Boundary.DataContainer

  action_fallback RandomWeb.FallbackController

  def index(conn, _params) do
    result = DataContainer.users_with_points_gt_min_number()
    render(conn, :index, data: result)
  end
end
