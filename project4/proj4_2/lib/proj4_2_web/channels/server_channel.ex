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

    def handle_in("logout", %{"body" => body}, socket) do
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.logout(EngineServer,userName,passWord)
      IO.inspect(flag)
      {:reply, {:ok,%{flag: flag}}, socket}
    end

    def handle_in("delete", %{"body" => body}, socket) do
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.delete(EngineServer,userName,passWord)
      IO.inspect(flag)
      {:reply, {:ok,%{flag: flag}}, socket}
    end

    def handle_in("sendTweet", %{"body" => body}, socket) do
      userName = List.first(body)
      content = Enum.at(body,1)
      
      tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
      #IO.inspect(tmp,label: "tmp")
      hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

      tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
      mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

      Engine.send_tweet(EngineServer,userName,content,mentions,hashTags,socket)

      broadcast(socket,"transport",%{"userID" => mentions,"hashTag" => hashTags, "content" => content})
      {:noreply, socket}
    end

  end