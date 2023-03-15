defmodule RandomWeb.UserControllerTest do
  use RandomWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert json_response(conn, 200)["data"] == nil
    end
  end
end
