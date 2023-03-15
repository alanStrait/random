defmodule RandomWeb.UserController do
  use RandomWeb, :controller

  action_fallback RandomWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index, data: Random.users_with_points_gt_min_number())
  end
end
