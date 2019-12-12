defmodule Proj42Web.ServerChannel do
    use Phoenix.Channel
  
    def join("server:lobby", _message, socket) do
      {:ok, socket}
    end
    def join("server:" <> _private_room_id, _params, _socket) do
      {:error, %{reason: "unauthorized"}}
    end
    def handle_in("register", %{"body" => body}, socket) do
        tPid = socket.transport_pid
        userName = List.first(body)
        passWord = Enum.at(body,1)
        flag = Engine.register(EngineServer,userName,passWord,tPid,0)
        {:reply, {:ok,%{flag: flag}},socket}
    end

    def handle_in("login", %{"body" => body}, socket) do
      tPid = socket.transport_pid
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.login(EngineServer,userName,passWord,tPid)
      IO.inspect(flag)
      {:reply, {:ok,%{flag: flag}}, socket}
  end
  end