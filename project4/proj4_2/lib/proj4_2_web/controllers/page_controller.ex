defmodule Proj42Web.PageController do
  use Proj42Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
