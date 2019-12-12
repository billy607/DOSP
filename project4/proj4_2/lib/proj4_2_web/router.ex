defmodule Proj42Web.Router do
  use Proj42Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Proj42Web do
    pipe_through :browser

    get "/", PageController, :index

    get "/register", PageController, :register
    get "/login", PageController, :login
    get "/main", PageController, :main
    get "/delete", PageController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", Proj42Web do
  #   pipe_through :api
  # end
end
