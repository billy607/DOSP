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
      IO.inspect(flag, label: "when login")
      {:reply, {:ok,%{flag: flag}}, socket}
    end

    def handle_in("subscribe", %{"body" => body}, socket) do
      userName = List.first(body)
      subscribedName = Enum.at(body,1)
      flag =
      if !Enum.empty?(:ets.lookup(:user,subscribedName)) do
        Engine.subscribe(EngineServer,userName,subscribedName)
        true
      else
        false
      end
      IO.inspect(flag, lable: "when subscribe")
      {:reply, {:ok,%{flag: flag}}, socket}
    end

    def handle_in("init", %{"body" => body}, socket) do
      tPid = socket.transport_pid
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.login(EngineServer,userName,passWord,tPid)
      
      flag=Enum.uniq(Enum.at(flag,1)++Enum.at(flag,2))++Enum.at(flag,3)

      #IO.inspect(flag,label: "flag!!@#!@#")
      {:reply, {:ok,%{flag: [true,flag]}}, socket}
    end

    def handle_in("logout", %{"body" => body}, socket) do
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.logout(EngineServer,userName,passWord)
      IO.inspect(flag,label: "when logout")
      {:reply, {:ok,%{flag: flag}}, socket}
    end

    def handle_in("delete", %{"body" => body}, socket) do
      userName = List.first(body)
      passWord = Enum.at(body,1)
      flag = Engine.delete(EngineServer,userName,passWord)
      IO.inspect(flag,label: "when delete")
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

      #get tweet id
      {:noreply, socket}
    end

    def handle_in("reTweet", %{"body" => body}, socket) do
      userName = List.first(body)
      content = Enum.at(body,1)
      oriId = Enum.at(body,2)
      {oriId,""} = Integer.parse(oriId)
      tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
      #IO.inspect(tmp,label: "tmp")
      hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

      tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
      mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

      Engine.retweet(EngineServer,userName,content,mentions,hashTags,oriId,socket)

      #get tweet id
      {:noreply, socket}
    end

    def handle_in("search", %{"body" => body}, socket) do
      userName = List.first(body)
      content = Enum.at(body,1)
      type = Enum.at(body,2)
      flag = Engine.query(EngineServer,type,content)
      IO.inspect(flag,label: "when query")
      {:reply, {:ok,%{flag: flag}}, socket}
    end

  end