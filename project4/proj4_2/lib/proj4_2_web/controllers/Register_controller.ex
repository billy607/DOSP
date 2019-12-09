defmodule Proj42Web.RegisterController do
  use Proj42Web, :controller

  def index(conn, _params) do
    render(conn, "register.html")
  end
end