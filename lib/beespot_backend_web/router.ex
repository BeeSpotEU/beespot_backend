defmodule BeespotBackendWeb.Router do
  use BeespotBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BeespotBackendWeb do
    pipe_through :api
  end
end
