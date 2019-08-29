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
    if location["id"] do
      IO.inspect(location)

      case BeespotBackend.Repo.get(BeespotBackend.BeespotBackendWeb.Location, location["id"]) do
        # Post not found, we build one
        nil -> %BeespotBackend.BeespotBackendWeb.Location{id: location["id"]}
        # Post exists, let's use it
        found -> found
      end
      |> BeespotBackend.BeespotBackendWeb.Location.changeset(location)
      |> BeespotBackend.Repo.insert_or_update()
      |> handle_insert_result(socket)
      |> broadcast_new_location(socket)
    else
      BeespotBackend.BeespotBackendWeb.Location.changeset(
        %BeespotBackend.BeespotBackendWeb.Location{},
        location
      )
      |> BeespotBackend.Repo.insert()
      |> handle_insert_result(socket)
      |> broadcast_new_location(socket)
    end
  end

  defp handle_insert_result({:ok, location}, socket) do
    push(socket, "created_location", %{body: location})
    {:ok, location}
  end

  defp handle_insert_result({:error, changeset}, socket) do
    push(socket, "error_create_location", %{body: changeset})
    {:error, changeset}
  end

  defp broadcast_new_location({:ok, location}, socket) do
    broadcast!(socket, "new_location", %{body: location})
    location
  end

  defp broadcast_new_location({:error, changeset}, _socket) do
    {:error, changeset}
  end
end
