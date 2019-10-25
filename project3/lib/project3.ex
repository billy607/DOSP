defmodule TNode do
  use GenServer
  #pid:当前节点ip地址
  #guid:文件编号
  #aid:存有文件的节点的ip地址
  #objectMap:文件编号->存有该文件的ip地址
  #neighbor:节点编号->节点ip地址
  #neighborMap:Tapestry的neighbor Map
  #init:bool true:此node为初始node

  #neighborMap需初始化为"NULL:!!!!!!!!!!!!!!!!!!
  def start_link(nid,guid,objectMap,neighbor,neighborMap,init) do
    GenServer.start_link(__MODULE__,[nid,guid,objectMap,neighbor,neighborMap,init])
  end
  
  def init(list) do
    neighborMap = Enum.at(list,4)
    mNid = hd(list)
    d1 = elem(Integer.parse(String.at(mNid,0),16),0) - 1
    d2 = elem(Integer.parse(String.at(mNid,1),16),0) - 1
    d3 = elem(Integer.parse(String.at(mNid,2),16),0) - 1
    d4 = elem(Integer.parse(String.at(mNid,3),16),0) - 1
    temp = [d1,d2,d3,d4]
    neighborMap = [Enum.map(0..3,fn x -> List.replace_at(Enum.at(neighborMap,x),Enum.at(temp,x),mNid) end)]  #将自己添加到neighbormap中

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
      list = insert(mNid,initPid,list)
      {:ok,list}
    end
  end

  def insert(mNid,initPid,list) do
    mPid = self()
    acqPriSurrogate(initPid,mNid,mPid,1)                    #handle cast
    IO.puts("waiting surrogate node to give response...")
    list = 
    receive do
      {:surrogate, surrogateNid,surrogatePid} -> 
        IO.puts("get surrogate node doing insertion...")
        a = greatCommonPrefix(mNid,surrogateNid)            #function
        neighborMap = getPrelimNeighborMap(surrogatePid)    #handle call
        list = List.replace_at(list,4,neighborMap)
        ackMulticast(surrogatePid,a,mNid,mPid)    #handle cast
        list = acqNeighborMap(surrogateNid,surrogatePid,list)
        list
        IO.puts("insertion finish")
    end 
  end

  def acqNeighborMap(surrogateNid,surrogatePid,list) do
    mNid = hd(list)
    mPid = self()
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    a = greatCommonPrefix(mNid,surrogateNid)
    maxLevel = length(a)
    list = ackMulticastInBuildTable(surrogatePid,a,mNid,mPid)
    list = trim(list)       #find closest nodes not implement yet
    neighborMapAtlvl = buildTableFromList(list,maxLevel)
    neighborMap = List.replace_at(neighborMap,maxLevel-1,neighborAtLvl)
    #########
    temp = 
    Enum.map(maxLevel-1..0,fn x->
      list = getNextList()
      buildTableFromList(list,x)
    end)
  end

  def greatCommonPrefix(mNid,surrogateNid) do
    d1 = String.at(mNid,0)
    d2 = String.at(mNid,1)
    d3 = String.at(mNid,2)
    d4 = String.at(mNid,3)
    list1 = [d1,d2,d3,d4]
    s1 = String.at(surrogateNid,0)
    s2 = String.at(surrogateNid,1)
    s3 = String.at(surrogateNid,2)
    s4 = String.at(surrogateNid,3)
    list2 = [s1,s2,s3,s4]
    list3 = Enum.map(0..3,fn x -> 
      if(Enum.at(list1,x) == Enum.at(list2,x), do: 1, else: 0)
    end)
    index = Enum.find_index(list3, fn x -> x==0 end)
    if index == 0 do
      []
    else
      if index == nil do
        list1
      else
        Enum.slice(list1,0..index-1)
      end
    end

  end

  def ackMulticastInBuildTable(surrogatePid,a,newNNid,newNPid) do
    GenServer.cast(surrogatePid,{:ackMulticastIBT,a,newNNid,newNPid})
  end

  def ackMulticast(surrogatePid, a, newNNid, newNPid) do
    GenServer.cast(surrogatePid,{:ackMulticast,a,newNNid,newNPid})
  end

  def getPrelimNeighborMap(surrogatePid) do
    GenServer.call(__MODULE__, {:getPreNeiMap, surrogatePid})
  end

  def acqPriSurrogate(initPid,srcNid,srcPid,lvl) do
    GenServer.cast(initPid,{:acqPriSurrogate,srcNid,srcPid,lvl})
  end

  def buildNeighborMap(pid,nid,aid,lvl) do
    GenServer.cast(pid,{:buildNeiMap,nid,aid,lvl})
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

  def handle_cast({:ackMulticast,a,newNNid,newNPid},list) do
    mNid = hd(list)
    lvl = length(a)
    nextDigit = elem(Integer.parse(String.at(newNNid,lvl),16),0)
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    neighborAtLvl = Enum.at(neighborMap,lvl-1)
    if Enum.find_value(neighborAtLvl,fn x -> x!="NULL"&&x!=mNid end) do
      Enum.map(0..15,fn x ->
        if Enum.at(neighborAtLvl,x)!="NULL" do
          TNode.ackMulticast(neighbor[Enum.at(neighborAtLvl,x)],Enum.slice(Enum.at(neighborAtLvl,x),0..lvl),newNPid,newNPid)
        end
      end)
    else
      if Enum.at(neighborAtLvl,nextDigit)=="NULL" do
        neighborMap = List.replace_at(Enum.at(neighborMap,lvl-1),nextDigit,newNNid)
        neighbor = Map.put(neighbor,newNNid,newNPid)
      end
    end
    list = List.replace_at(list,4,neighborMap)
    list = List.replace_at(list,3,neighbor)
    {:noreply,list}
  end

  def handle_cast({:ackMulticastIBT,a,newNNid,newNPid,fatherPid},list) do
    mNid = hd(list)
    lvl = length(a)
    nextDigit = elem(Integer.parse(String.at(newNNid,lvl),16),0)
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    neighborAtLvl = Enum.at(neighborMap,lvl-1)
    numChild = 
    if Enum.find_value(neighborAtLvl,fn x -> (x!="NULL")&&(x!=mNid) end) do
      Enum.map(0..15,fn x ->
        if Enum.at(neighborAtLvl,x)!="NULL" do
          TNode.ackMulticast(neighbor[Enum.at(neighborAtLvl,x)],Enum.slice(Enum.at(neighborAtLvl,x),0..lvl),newNPid,newNPid,self()))
        end
      end)
      length(List.delete(Enum.uniq(neighborAtLvl),"NULL"))
    else
      0
    end
    listMap = %{mNid=>self()}
    listMap = functionS(numChild,listMap)
    send fatherPid,{:ack,listMap}
    {:noreply,list}
  end

  def functionS(n,listMap) when n==0 do
		listMap
	end
	def functionS(n,listMap) do
		receive do
      {:ack,neiNid,neiPid}->
        listMap = Map.put(listMap,neiNid,neiPid)
        functionS(n-1,listMap)
		after
			3->
				IO.inspect(n, label: "dead in ackMulticastIBT!")
		end
	end

  def handle_cast({:acqPriSurrogate,srcNid,srcPid,lvl},list) do
    mNid = List.first(list)
    neighborMap = Enum.at(list,4)   ######
    neighbor = Enum.at(list,3)
    nextN = nextHop(mNid,lvl,srcNid,neighborMap)
    if nextN != mNid do
      TNode.acqPriSurrogate(neighbor[nextN],srcNid,lvl+1,srcPid)
    else
      send srcPid,{:surrogate,mNid,self()}
    end
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

  def handle_call({:getPreNeiMap, surrogatePid}, _from, list) do
    neighborMap = Enum.at(list,4)
    {:reply, neighborMap, list}
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
