defmodule BeespotBackendWeb.LocationChannel do
  use Phoenix.Channel

  def join("locations:lobby", _message, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("locations:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("add_location", %{"body" => body}, socket) do
    spawn(fn -> save_location(body, socket) end)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    previous_locations()
    |> Enum.each(fn location ->
      push(socket, "new_location", %{
        body: location
      })
    end)

    {:noreply, socket}
  end

  def previous_locations() do
    BeespotBackend.Repo.all(BeespotBackend.BeespotBackendWeb.Location)
  end

  defp save_location(location, socket) do
    BeespotBackend.BeespotBackendWeb.Location.changeset(
      %BeespotBackend.BeespotBackendWeb.Location{},
      location
    )
    |> BeespotBackend.Repo.insert_or_update()
    |> handle_insert_result(socket)
    |> broadcast_new_location(socket)
  end

  defp handle_insert_result({:ok, location}, socket) do
    push(socket, "created_location", %{body: location})
    location
  end

  defp broadcast_new_location(location, socket) do
    broadcast!(socket, "new_location", %{body: location})
    location
  end
end
