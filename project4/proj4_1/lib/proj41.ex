defmodule Engine do
  use GenServer
  #user:[user_id,user_pwd,user_ip,connect]
  #subscribe:[user_id,user_id2]
  #tweet:[tweet_id,publisher,content]
  #mention:[tweet_id,user_id(mentions)]
  #hashTags:[hashtag,tweet_id]
  def start_link() do
    GenServer.start_link(__MODULE__,[])
  end

  def init(list) do
    :ets.new(:user,[:set, :protected, :named_table])
    :ets.new(:subscribe, [:bag, :protected, :named_table])
    :ets.new(:tweet, [:set, :protected, :named_table])
    :ets.new(:mention, [:bag, :protected, :named_table])
    :ets.new(:hashTags, [:bag, :protected, :named_table])
    {:ok,list}
  end

  def find(tName,key) do
    :ets.lookup(tName,key)
  end

  def register(pid,uid,pwd,ip,connect) do
    GenServer.cast(pid,{:register, uid,pwd,ip,connect})
  end

  def subscribe(pid,uid,follow) do
    GenServer.cast(pid,{:subscribe, uid,follow})
  end

  def login(pid,uid,pwd,ip) do
    Genserver.call(pid,{:login, uid,pwd,ip})
  end

  def handle_cast({:register, uid,pwd,ip,connect}, state) do
    :ets.insert(:user, {uid,pwd,ip,connect})
    {:noreply, state}
  end

  def handle_cast({:subscribe, uid,follow}, state) do
    :ets.insert(:subscribe, {uid,follow})
    {:noreply, state}
  end

  def handle_call({:login, uid,pwdIn,ip}, state) do
    user = :ets.lookup(:user,uid)
    if Enum.empty?(user) do
      {:reply, [false,"User name invalid"], state}
    end
    pwd = Enum.at(Tuple.to_list(List.first(user)),1)
    if(pwd != pwdIn) do
      {:reply, [false,"Wrong password"], state}
    end

    :ets.insert(:user, {uid,pwd,ip,1})
    #deliver subscribed users' tweets and tweets mentiond

    {:reply, [true,[]], state}
  end
end

defmodule Client do
  use GenServer
end
