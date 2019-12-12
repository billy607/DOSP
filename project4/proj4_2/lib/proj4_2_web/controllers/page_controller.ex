defmodule Proj42Web.PageController do
  use Proj42Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def register(conn, _params) do
    IO.puts("controller")
    render(conn,"register.html")
  end

  def login(conn, _params) do
    render(conn,"login.html")
  end

  def main(conn, _params) do
    render(conn,"main.html")
  end
end
