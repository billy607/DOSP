defmodule Engine do
  use GenServer
  #user:[user_id,user_pwd,user_ip,connect]
  #subscribe:[user_id,user_id2]
  #tweet:[tweet_id,publisher_id,content,retweet_id]
  #mention:[tweet_id,user_id(mention)]
  #hashTags:[hashtag,tweet_id]
  def start_link(_a) do
    GenServer.start_link(__MODULE__,:ok,name: EngineServer)
  end

  def init(_list) do
    :ets.new(:user,[:set, :protected, :named_table])
    :ets.new(:subscribe, [:bag, :protected, :named_table])
    :ets.new(:tweet, [:set, :protected, :named_table])
    :ets.new(:mention, [:bag, :protected, :named_table])
    :ets.new(:hashTags, [:bag, :protected, :named_table])
    Enum.map(1..100,fn x -> 
      :ets.insert(:user,{Integer.to_string(x),"a",x,0})
    end)
    Enum.map(2..100,fn x ->
      :ets.insert(:subscribe,{"1",Integer.to_string(x)})
    end)
    Enum.map(2..100,fn x ->
      :ets.insert(:tweet,{x-1,Integer.to_string(x),"I am "<>Integer.to_string(x),nil})
    end)

    {:ok,[100,99]}#[user_num,tweet_num]
  end

  def demo() do
    Enum.map(1..99,fn x -> 
      Engine.send_tweet(EngineServer,Integer.to_string(x) ,"hello",[],[],nil)
    end)
  end

  def find(tName,key) do
    :ets.lookup(tName,key)
  end

  def demo(pid) do
    GenServer.cast(pid,{:demo})
  end

  def register(pid,uid,pwd,ip,connect) do
    GenServer.call(pid,{:register, uid,pwd,ip,connect})
  end

  def delete(pid,uid,pwd) do
    GenServer.call(pid,{:delete,uid,pwd})
  end

  def subscribe(pid,uid,follow) do
    GenServer.cast(pid,{:subscribe, uid,follow})
  end

  def login(pid,uid,pwd,ip) do
    GenServer.call(pid,{:login, uid,pwd,ip})
  end

  def logout(pid,uid,pwd) do
    GenServer.call(pid,{:logout, uid,pwd})
  end

  def send_tweet(pid,uid,content,mention,hashTags,socket) do
    GenServer.cast(pid,{:send_tweet, uid,content,mention,hashTags,socket})
  end

  def query(pid,type,content) do
    GenServer.call(pid,{:query,type,content})
  end

  def retweet(pid,uid,content,mention,hashTags,retweetId,socket) do
    GenServer.cast(pid,{:re_tweet, uid,content,mention,hashTags,retweetId,socket})
  end


  def handle_cast({:subscribe, uid,follow}, state) do
    :ets.insert(:subscribe, {uid,follow})
    {:noreply, state}
  end

  def handle_cast({:re_tweet, uid,content,mention,hashTags,retweetId,socket},state) do
    tweet_id=List.last(state)

    oriContent = Enum.at(Tuple.to_list(hd(:ets.lookup(:tweet,retweetId))),2)
    oriPublisher = Enum.at(Tuple.to_list(hd(:ets.lookup(:tweet,retweetId))),1)

    content = content<>" // "<>oriPublisher<>": "<>oriContent
    
    IO.inspect(content,label: " content")

    :ets.insert(:tweet,{tweet_id,uid,content,retweetId})
    #hashtag
    Enum.each(hashTags,fn(x)->
      :ets.insert(:hashTags,{x,tweet_id})
    end)
    #mention
    Enum.map(mention,fn(x)->
      :ets.insert(:mention,{tweet_id,x}) 
    end)
    #subscribe
    followers=List.flatten(:ets.match(:subscribe,{:"$1",uid}))
    #IO.inspect(%{"userID" => mention,"follower" => followers, "hashTag" => hashTags, "senderName" => uid ,"tweet" => [tweet_id,content]},label: "transport content")
    IO.inspect(content,label: "content2")
    Phoenix.Channel.broadcast(socket,"transport",%{"userID" => mention++[uid],"follower" => followers, "hashTag" => hashTags, "senderName" => uid ,"tweet" => [tweet_id,content]})
    {:noreply, List.replace_at(state,1,tweet_id+1)}
  end

  def handle_cast({:send_tweet, uid,content,mention,hashTags,socket},state) do
    tweet_id=List.last(state)
    :ets.insert(:tweet,{tweet_id,uid,content,nil})
    #hashtag
    Enum.each(hashTags,fn(x)->
      :ets.insert(:hashTags,{x,tweet_id})
    end)
    #mention
    Enum.map(mention,fn(x)->
      :ets.insert(:mention,{tweet_id,x}) 
    end)
    #subscribe
    followers=List.flatten(:ets.match(:subscribe,{:"$1",uid}))
    #IO.inspect(%{"userID" => mention,"follower" => followers, "hashTag" => hashTags, "senderName" => uid ,"tweet" => [tweet_id,content]},label: "transport content")
    Phoenix.Channel.broadcast(socket,"transport",%{"userID" => mention++[uid],"follower" => followers, "hashTag" => hashTags, "senderName" => uid ,"tweet" => [tweet_id,content,nil]})
    {:noreply, List.replace_at(state,1,tweet_id+1)}
  end

  def handle_cast({:demo}, _state ) do
    :ets.insert(:user,{"A","a",123,0})
    :ets.insert(:user,{"B","a",234,0})
    :ets.insert(:user,{"C","a",345,0})
    :ets.insert(:user,{"D","a",666,0})
    :ets.insert(:subscribe,{"A","B"})
    :ets.insert(:subscribe,{"A","C"})
    :ets.insert(:tweet,{0,"B","abc",nil})
    :ets.insert(:tweet,{1,"C","def",nil})
    :ets.insert(:tweet,{2,"D","lzq",nil})
    :ets.insert(:tweet,{3,"D","lzq22",nil})
    :ets.insert(:mention,{2,"A"})
    :ets.insert(:hashTags,{"lzq",0})
    :ets.insert(:hashTags,{"lzq",1})
    :ets.insert(:hashTags,{"kkkkk",2})
    {:noreply, [4,4]}
  end

  def handle_call({:register, uid,pwd,ip,connect},_from, state) do 
    if !Enum.empty?(:ets.lookup(:user,uid)) do
      {:reply,false,state}
    else
      :ets.insert(:user, {uid,pwd,ip,connect})
      {:reply,true,List.replace_at(state,0,hd(state)+1)}
    end
  end

  def handle_call({:login, uid,pwdIn,ip},_from, state) do
    user = :ets.lookup(:user,uid)
    flag = if(Enum.empty?(user), do: false, else: true)
    [flag,pwd] = 
    if flag do
      pwd = Enum.at(Tuple.to_list(List.first(user)),1)
      if pwd == pwdIn ,do: [true,pwd], else: [false,nil]
    else
      [false,nil]
    end

    if flag do
      :ets.insert(:user, {uid,pwd,ip,1})
      #deliver subscribed users' tweets and tweets mentiond
      subscribed_users = List.flatten(:ets.match(:subscribe,{uid,:"$1"}))
      tweet_list_subscribe = []
      k=[]
      k = Enum.map(subscribed_users, fn(x)->
        k ++ :ets.match_object(:tweet,{:"$3",x,:"$2",:"$1"})
      end)
      k=List.flatten(k)
      tweet_list_subscribe = Enum.map(k,fn(x)->
        tweet_list_subscribe ++ Tuple.to_list(x)
      end)


      mention_tweets_id = List.flatten(:ets.match(:mention,{:"$1",uid}))
      tweet_list_mention = Enum.map(mention_tweets_id, fn(x) ->
        List.flatten(Tuple.to_list(List.first(:ets.lookup(:tweet,x))))
      end)

      tweet_list_self = List.flatten((:ets.match_object(:tweet,{:"$1",uid,:"$2",:"$3"})))
      tweet_list_self = Enum.map(tweet_list_self,fn(x)-> Tuple.to_list(x) end)

      {:reply, [flag,tweet_list_self,tweet_list_subscribe,tweet_list_mention], state}
    else
      {:reply, [flag,"invalid username or password!"], state}
    end
  end

  def handle_call({:logout, uid,pwdIn},_from, state) do
    user = :ets.lookup(:user,uid)
    flag = if(Enum.empty?(user), do: false, else: true)
    pwd = Enum.at(Tuple.to_list(List.first(user)),1)
    flag = if((pwd != pwdIn)&&flag, do: false, else: true)

    if flag do
      :ets.insert(:user, {uid,pwd,Enum.at(Tuple.to_list(List.first(user)),2),0})
      {:reply, true, state}
    else
      {:reply, false, state}
    end
    
  end

  def handle_call({:delete,uid,pwdIn},_from,state) do
    if Enum.empty?(:ets.match_object(:user,{uid,pwdIn,:"$1",:"$2"})) do
      {:reply,false,state}
    else
      :ets.delete(:user,uid)
      {:reply,true,List.replace_at(state,0,hd(state)-1)}
    end
  end

  def handle_call({:query,type,content},_from,state) do
    case type do
      0->#user
        if Enum.empty?(:ets.lookup(:user,content)) do
          {:reply,[false,[]],state}
        end
        tweets=:ets.match_object(:tweet,{:"$1",content,:"$2",:"$3"})
        tweets=Enum.map(tweets,fn(x)-> Tuple.to_list(x) end)
        {:reply,[true,tweets],state}
      1->#hashtag
        if Enum.empty?(:ets.lookup(:hashTags,content)) do
          {:reply,[false,[]],state}
        end
        tId_list = List.flatten(:ets.match(:hashTags,{content,:"$1"}))
        tweets = Enum.map(tId_list,fn(x) -> Tuple.to_list(List.first(:ets.lookup(:tweet,x))) end)
        {:reply,[true,tweets],state}
      _->#mention
        if Enum.empty?(:ets.match(:mention,{:"$1",content})) do
          {:reply,[false,[]],state}
        end
        tweets_id = List.flatten(:ets.match(:mention,{:"$1",content}))
        tweets = Enum.map(tweets_id, fn(x) -> Tuple.to_list(List.first(:ets.lookup(:tweet,x))) end)
        {:reply,[true,tweets],state}
    end
  end

end

