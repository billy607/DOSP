defmodule Client do
    use GenServer
  
    def start_link(serverIP) do
      GenServer.start_link(__MODULE__,[serverIP])
    end
  
    def init(list) do
      {:ok,list}#list = serverIP address
    end
  
    def register(uid,pwd) do
        ip = self()
        serverIP = hd(:sys.get_state(ip))
        if Engine.register(serverIP,uid,pwd,ip,0) do
            IO.puts("register success")
        else
            IO.puts("register failed")
        end
    end
  
    def delete(uid,pwd) do
        serverIP = hd(:sys.get_state(self()))
        if Engine.delete(serverIP,uid,pwd) do
            IO.puts("delete success")
        else
            IO.puts("delete failed")
        end
    end
  
    def subscribe(uid,follow) do
        serverIP = hd(:sys.get_state(self()))
        Engine.subscribe(serverIP,uid,follow)
    end
  
    def login(uid,pwd) do
        serverIP = hd(:sys.get_state(self()))
        res = Engine.login(serverIP,uid,pwd,self())
        IO.inspect(res)
        if hd(res) do
            :sys.replace_state self(), fn state -> [state] ++ [uid,pwd] end
        end
    end
  
    def logout() do
        serverIP = hd(:sys.get_state(self()))
        uid = Enum.at(:sys.get_state(self()),1)
        pwd = Enum.at(:sys.get_state(self()),2)
        if Engine.logout(serverIP,uid,pwd) do
            IO.puts("logout success")
        else
            IO.puts("logout failed")
        end
    end
  
    def send_tweet(content) do
        #uid,content,mention,hashtag
        serverIP = hd(:sys.get_state(self()))
        uid = Enum.at(:sys.get_state(self()),1)
        pwd = Enum.at(:sys.get_state(self()),2)

        tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
        hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

        tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
        mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

        Engine.send_tweet(serverIP,uid,pwd,mentions,hashTags)
    end
  
    def query(pid,type,content) do
      GenServer.call(pid,{:query,type,content})
    end
  
    def retweet(pid,uid,content,mention,hashTags,retweetId) do
      GenServer.cast(pid,{:re_tweet, uid,content,mention,hashTags,retweetId})
    end

    def handle_cast({:register,uid,pwd},state) do
        ip = self()
        serverIP = hd(state)
        if Engine.register(serverIP,uid,pwd,ip,0) do
            IO.puts("register success")
        else
            IO.puts("register failed")
        end
        {:noreply,state}
    end

    def handle_cast({:delete},state) do
        serverIP = hd(state)
        uid = Enum.at(:sys.get_state(self()),1)
        pwd = Enum.at(:sys.get_state(self()),2)
        if Engine.delete(serverIP,uid,pwd) do
            IO.puts("delete success")
        else
            IO.puts("delete failed")
        end
        {:noreply,state}
    end

    def handle_cast({:subscribe,follow},state) do
        serverIP = hd(state)
        uid = Enum.at(:sys.get_state(self()),1)
        Engine.subscribe(serverIP,uid,follow)
        {:noreply,state}
    end

    def handle_cast({:login,uid,pwd},state) do
        serverIP = hd(state)
        res = Engine.login(serverIP,uid,pwd,self())
        IO.inspect(res)
        if hd(res) do
            {:noreply,state++[uid,pwd]}
        end
        {:noreply,state}
    end

    def handle_cast({:logout},state) do
        serverIP = hd(:sys.get_state(self()))
        uid = Enum.at(:sys.get_state(self()),1)
        pwd = Enum.at(:sys.get_state(self()),2)
        if Engine.logout(serverIP,uid,pwd) do
            IO.puts("logout success")
        else
            IO.puts("logout failed")
        end
        {:noreply,state}
    end

    def handle_cast({:send_tweet,content},state) do
        #uid,content,mention,hashtag
        serverIP = hd(:sys.get_state(self()))
        uid = Enum.at(:sys.get_state(self()),1)
        pwd = Enum.at(:sys.get_state(self()),2)

        tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
        hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

        tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
        mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

        Engine.send_tweet(serverIP,uid,pwd,mentions,hashTags)
        {:noreply,state}
    end
  end
  