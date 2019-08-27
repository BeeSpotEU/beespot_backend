defmodule BeespotBackendWeb.LocationChannel do
  use Phoenix.Channel

  def join("locations:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("locations:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("add_location", %{"body" => body}, socket) do
    spawn(fn -> save_location(body, socket) end)
    {:noreply, socket}
  end

  defp save_location(location, socket) do
    BeespotBackend.BeespotBackendWeb.Location.changeset(
      %BeespotBackend.BeespotBackendWeb.Location{},
      location
    )
    |> BeespotBackend.Repo.insert()
    |> broadcast_new_location(socket)
  end

  defp broadcast_new_location({:ok, location}, socket) do
    IO.inspect(location)
    broadcast!(socket, "new_location", %{body: location})
  end
end
