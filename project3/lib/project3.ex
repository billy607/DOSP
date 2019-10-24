defmodule TNode do
  use GenServer
  #pid:当前节点ip地址
  #guid:文件编号
  #aid:存有文件的节点的ip地址
  #objectMap:文件编号->存有该文件的ip地址
  #neighbor:节点编号->节点ip地址
  #neighborMap:Tapestry的neighbor Map
  #init:bool true:此node为初始node

  def init(list) do
    if Enum.at(list,5) do
      mPid = self()
      Process.register(mPid,:initPid)
      sha1 = :crypto.hash(:sha, Kernel.inspect(mPid)) |> Base.encode16
      mNid = String.slice(sha1,0..3)
      {:ok,List.replace_at(list,0,mNid)}
    else
      mPid = self()
      sha1 = :crypto.hash(:sha, Kernel.inspect(mPid)) |> Base.encode16
      mNid = String.slice(sha1,0..3)
      list = List.replace_at(list,0,mNid)

      initPid = Process.whereis(:initPid)
      insert(mNid,initPid,list)
      {:ok,list}
    end
  end

  def insert(mNid,initPid,list) do
    [surrogateNid,surrogatePid] = acqPriSurrogate(initPid,mNid) #handle call
    a = greatCommonPrefix(mNid,surrogateNid)            #function
    neighborMap = getPrelimNeighborMap(surrogatePid)    #handle call
    ackMulticast(surrogatePid,a)    #handle cast
    #ackMulticast会让其他节点调用buildNeighborMap帮助当前节点构建NeighborMap
  end

  def acqPriSurrogate(initPid,mNid) do
    GenServer.call(__MODULE__,{:acqPriSurrogate,initPid,mNid})
  end

  def buildNeighborMap(pid,nid,aid,lvl) do
    GenServer.cast(pid,{:buildNeiMap,nid,aid,lvl})
  end

  def start_link(nid,guid,objectMap,neighbor,neighborMap,init) do
    GenServer.start_link(__MODULE__,[nid,guid,objectMap,neighbor,neighborMap,init])
  end

  def routeToObj(pid,guid,lvl,srcPid) do
    GenServer.cast(pid,{:routeToObj,guid,lvl,srcPid})
  end

  def routeToNode(pid,nid,lvl,srcPid,numHop) do
    GenServer.cast(pid,{:routeToNode,nid,lvl,srcPid,numHop})
  end

  def publishObj(pid,guid,aid,lvl) do
    GenServer.cast(pid,{:publish,guid,aid,lvl})
  end

  def handle_call({:acqPriSurrogate,initPid,mNid},_from,list) do
    
  end

  def handle_cast({:routeToNode,pid,nid,lvl,srcPid,numHop},list) do
    mNid = List.first(list)
    numHop = numHop + 1
    if mNid == nid do
      send :main, {:compareNumHop,numHop}
    else
      neighborMap = Enum.at(list,4)
      neighbor = Enum.at(list,3)
      nextN = nextHop(mNid,lvl,nid,neighborMap)
      if nextN != mNid do
        TNode.routeToNode(neighbor[nextN],nid,lvl+1,srcPid,numHop)
      else
        IO.puts("error0,cannot find such node")
      end
      {:noreply,list}
    end
  end

  def handle_cast({:routeToObj,pid,guid,lvl,srcPid},list) do
    objMap = Enum.at(list,2)
    if Map.has_key?(objMap,guid) do
      #send objMap[guid] to srcPid
    else
      mNid = List.first(list)
      neighborMap = Enum.at(list,4)
      neighbor = Enum.at(list,3)
      nextN = nextHop(mNid,lvl,guid,neighborMap)
      if nextN != mNid do
        TNode.routeToObj(neighbor[nextN],guid,lvl+1,srcPid)
      else
        IO.puts("error0,no such object")
      end
      {:noreply,list}
    end
  end

  def handle_cast({:publish,guid,aid,lvl},list) do
    objMap = Map.put(Enum.at(list,2),guid,aid)
    mNid = List.first(list)
    neighborMap = Enum.at(list,4)
    neighbor = Enum.at(list,3)
    nextN = nextHop(mNid,lvl,guid,neighborMap)
    if nextN != mNid do
      TNode.publishObj(neighbor[nextN],guid,aid,lvl+1)
    end
    {:noreply, List.replace_at(list,2,objMap)}
  end

  def nextHop(mNid,lvl,matchID,neighborMap) do    #matchID 需要查找的目标ID
    if lvl>4 do
      mNid
    else
      d = elem(Integer.parse(String.at(matchID,lvl-1),16),0)
      e = Enum.at(Enum.at(neighborMap,lvl-1),d-1)
      e = 
      if e == "NULL" do
        #list = Enum.map(0..14,fn x -> Enum.at(Enum.at(neighborMap,lvl-1),rem(x+d+1,16)) end)
        #hd(List.delete(Enum.uniq(list),"NULL"))
        allNeighbor = Enum.at(neighborMap,lvl-1)
        e = Enum.min_by(allNeighbor,fn x -> abs(elem(Integer.parse(x,16),0)-elem(Integer.parse(matchID,16),0)) end)
      else
        e
      end
      if e == mNid do
        nextHop(mNid,lvl+1,matchID,neighborMap)
      else
        e
      end
    end
  end


  def test(nNode,nReq) do
    IO.inspect({nNode,nReq},label: "test")
  end
end
