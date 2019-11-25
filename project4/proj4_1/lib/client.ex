defmodule Client do
    use GenServer
  
    def start_link(serverIP) do
      GenServer.start_link(__MODULE__,[serverIP])
    end
  
    def init(list) do
      {:ok,list++["","",[],[],[],[]]}
      #list = [serverIP address,uid,pwd,send_tweet,subscribe_tweet,mentionme_tweet,queryRES]
    end

    def register(pid,uid,pwd) do
        GenServer.cast(pid,{:register,uid,pwd})
    end

    def delete(pid) do
        GenServer.cast(pid,{:delete})
    end

    def subscribe(pid,follow) do
        GenServer.cast(pid,{:subscribe,follow})
    end

    def login(pid,uid,pwd) do
        GenServer.cast(pid,{:login,uid,pwd})
    end

    def logout(pid) do
        GenServer.cast(pid,{:logout})
    end

    def send_tweet(pid,content) do
        GenServer.cast(pid,{:send_tweet,content})
    end

    def re_tweet(pid,content,retweet_id) do
        GenServer.cast(pid,{:re_tweet,content,retweet_id})
    end

    def receive_tweet(pid,content,type) do
        GenServer.cast(pid,{:receive,content,type})
    end

    def query(pid,type,content) do
        GenServer.cast(pid,{:query,type,content})
    end

    def handle_cast({:register,uid,pwd},state) do
        ip = self()
        serverIP = hd(state)
        if Engine.register(serverIP,uid,pwd,ip,0) do
            IO.inspect([self(),"register success"])
        else
            IO.inspect([self(),"register failed"])
        end
        {:noreply,state}
    end

    def handle_cast({:delete},state) do
        serverIP = hd(state)
        uid = Enum.at(state,1)
        pwd = Enum.at(state,2)
        if Engine.delete(serverIP,uid,pwd) do
            IO.inspect([self(),"delete success"])
        else
            IO.inspect([self(),"delete success"])
        end
        {:noreply,[hd(state)]}
    end

    def handle_cast({:subscribe,follow},state) do
        serverIP = hd(state)
        uid = Enum.at(state,1)
        Engine.subscribe(serverIP,uid,follow)
        {:noreply,state}
    end

    def handle_cast({:login,uid,pwd},state) do
        serverIP = hd(state)
        res = Engine.login(serverIP,uid,pwd,self())
        IO.inspect([self(),res], label: "login status")
        if hd(res) do
            {:noreply,List.replace_at(List.replace_at(state,1,uid),2,pwd)}
        else
            {:noreply,state}
        end
    end

    def handle_cast({:logout},state) do
        serverIP = hd(state)
        uid = Enum.at(state,1)
        pwd = Enum.at(state,2)
        if Engine.logout(serverIP,uid,pwd) do
            IO.puts("logout success")
        else
            IO.puts("logout failed")
        end
        {:noreply,state}
    end

    def handle_cast({:send_tweet,content},state) do
        #uid,content,mention,hashtag
        serverIP = hd(state)
        uid = Enum.at(state,1)

        #IO.inspect(content, label: "content")
        tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
        #IO.inspect(tmp,label: "tmp")
        hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

        tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
        mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

        Engine.send_tweet(serverIP,uid,content,mentions,hashTags)

        {:noreply,state}
    end

    def handle_cast({:re_tweet,content,retweet_id},state) do
        serverIP = hd(state)
        uid = Enum.at(state,1)

        tmp = List.flatten(Regex.scan(~r/#.*?\s/, content))
        hashTags = Enum.map(tmp, fn(x) -> Regex.replace(~r/#|\s/,x,"") end)

        tmp = List.flatten(Regex.scan(~r/@.*?\s/, content))
        mentions = Enum.map(tmp, fn(x) -> Regex.replace(~r/@|\s/,x,"") end)

        Engine.retweet(serverIP,uid,content,mentions,hashTags,retweet_id)

        {:noreply,state}
    end

    def handle_cast({:receive,tweet,type},state) do
        case type do
            0 -> #subscribe
                {:noreply,List.replace_at(state,4,Enum.at(state,4) ++ [tweet])}
            1 -> #mention me
                {:noreply,List.replace_at(state,5,Enum.at(state,5) ++ [tweet])}
            _ ->
                IO.puts("error")
        end
    end

    def handle_cast({:query,type,content},state) do
        serverIP = hd(state)
        queryRES = Engine.query(serverIP,type,content)
        if Enum.at(queryRES,0) do
            {:noreply,List.replace_at(state,6,Enum.at(state,5) ++ Enum.at(queryRES,1))}
        else
            IO.inspect([self(),"no result for query"],label: "query")
            {:noreply,state}
        end
    end
  end
  