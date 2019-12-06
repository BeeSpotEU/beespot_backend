import Ecto.Query

defmodule BeespotBackendWeb.LocationChannel do
  use Phoenix.Channel
  alias BeespotBackend.Presence

  def join("locations:lobby", _message, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def join("locations:" <> session_id, _params, socket) do
    # TODO: Does session id exist? if not -> return error

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    case String.split(socket.topic, ":") do
      ["locations", session_id] ->
        if(session_id != "lobby") do
          previous_locations(session_id)
          |> Enum.each(fn location ->
            push(socket, "new_location", %{
              body: location
            })
          end)
        end
    end

    {:noreply, socket}
  end

  def previous_locations(session_id) do
    session =
      BeespotBackend.Repo.get_by(BeespotBackend.BeespotBackendWeb.Session, session_id: session_id)

    query = from l in BeespotBackend.BeespotBackendWeb.Location, where: [session_id: ^session.id]

    BeespotBackend.Repo.all(query)
  end

  def handle_in("create_session", %{}, socket) do
    uuid = String.slice(Ecto.UUID.generate(), -4..-1)

    %BeespotBackend.BeespotBackendWeb.Session{session_id: uuid}
    |> BeespotBackend.Repo.insert()
    |> handle_insert_result_session(socket)

    {:noreply, socket}
  end

  def handle_in("add_location", %{"body" => body}, socket) do
    spawn(fn -> save_location(body, socket) end)
    {:noreply, socket}
  end

  def handle_insert_result_session({:ok, session}, socket) do
    push(socket, "created_session", %{body: session.session_id})
    {:ok, session}
  end

  def handle_insert_result_session({:error, changeset}, socket) do
    push(socket, "error_create_session", %{body: changeset})
    {:error, changeset}
  end

  defp save_location(location, socket) do
    ["locations", session_id] = String.split(socket.topic, ":")

    session =
      BeespotBackend.Repo.get_by!(BeespotBackend.BeespotBackendWeb.Session, session_id: session_id)

    if location["id"] do
      case BeespotBackend.Repo.get(BeespotBackend.BeespotBackendWeb.Location, location["id"]) do
        # Post not found, we build one
        nil ->
          %BeespotBackend.BeespotBackendWeb.Location{
            id: location["id"],
            session_id: session.id
          }

        # Post exists, let's use it
        found ->
          found
      end
    else
      %BeespotBackend.BeespotBackendWeb.Location{session_id: session.id}
    end
    |> BeespotBackend.BeespotBackendWeb.Location.changeset(location)
    |> BeespotBackend.Repo.insert_or_update()
    |> handle_insert_result_location(socket)
    |> broadcast_new_location(socket)
  end

  defp handle_insert_result_location({:ok, location}, socket) do
    push(socket, "created_location", %{body: location})
    {:ok, location}
  end

  defp handle_insert_result_location({:error, changeset}, socket) do
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
