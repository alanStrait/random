defmodule Random do
  @moduledoc """
  Random is a context module that serves as the public API for
  the overall application.

  Random keeps the contexts that define domain and business logic.

  Contexts are also responsible for managing data, regardless
  if it comes from the database, an external API or others.
  """
  alias Random.Accounts.Boundary.DataContainer

  @doc """
  Returns two or fewer users with points greater than a
  constantly changing and randomly generated number that is
  unknown externally.
  """
  def users_with_points_gt_min_number() do
    DataContainer.users_with_points_gt_min_number()
  end
end
