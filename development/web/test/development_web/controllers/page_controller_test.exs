defmodule DevelopmentWeb.PageControllerTest do
  use DevelopmentWeb.ConnCase

  test "GET / redirects to the showcase", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/showcase"
  end
end
