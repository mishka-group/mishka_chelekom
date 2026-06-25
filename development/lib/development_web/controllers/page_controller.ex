defmodule DevelopmentWeb.PageController do
  use DevelopmentWeb, :controller

  def home(conn, _params) do
    # The dev harness lands on the component showcase.
    redirect(conn, to: ~p"/showcase")
  end
end
