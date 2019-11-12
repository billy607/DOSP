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
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    mPid = self()
    sha1 = :crypto.hash(:sha, Kernel.inspect(mPid)) |> Base.encode16
    mNid = String.slice(sha1,0..3)
    d1 = elem(Integer.parse(String.at(mNid,0),16),0)
    d2 = elem(Integer.parse(String.at(mNid,1),16),0)
    d3 = elem(Integer.parse(String.at(mNid,2),16),0)
    d4 = elem(Integer.parse(String.at(mNid,3),16),0)
    temp = [d1,d2,d3,d4]
    neighborMap = Enum.map(0..3,fn x -> List.replace_at(Enum.at(neighborMap,x),Enum.at(temp,x),mNid) end)  #将自己添加到neighbormap中
    neighbor = Map.put(neighbor,mNid,mPid)
    list = List.replace_at(list,0,mNid)
    list = List.replace_at(list,3,neighbor)
    list = List.replace_at(list,4,neighborMap)

    if Enum.at(list,5) do
      Process.register(mPid,:initPid)
      IO.puts("first node insert success")
      IO.inspect(self(),label: "init pid!!!")
      IO.inspect(mNid,label: "init nid!!!")
      {:ok,list}
    else
      initPid = Process.whereis(:initPid)
      list = insert(mNid,initPid,list)
      {:ok,list}
    end
  end

  def insert(mNid,initPid,list) do
    mPid = self()
    IO.puts("waiting surrogate node to give response...")
    IO.inspect(mNid,label: "my nid")
    IO.inspect(self(),label: "my pid")
    [surrogateNid,surrogatePid] = acqPriSurrogate(initPid,mNid,mPid,1)                    #handle call
    IO.puts("get surrogate node doing insertion...")
    IO.inspect([surrogateNid,surrogatePid],label: "suunid,suupid")
    a = greatCommonPrefix(mNid,surrogateNid)            #function
    #neighborMap = getPrelimNeighborMap(surrogatePid)    #handle call
    #list = List.replace_at(list,4,neighborMap)
    ackMulticast(surrogatePid,a,mNid,mPid)    #handle cast让其他节点填补hole
    list = acqNeighborMap(surrogateNid,surrogatePid,list)
    IO.puts("insertion finish")
    IO.inspect(list,label: "list after insertion")
  end

  def acqNeighborMap(surrogateNid,surrogatePid,list) do
    IO.puts("acq neimap")
    mNid = hd(list)
    IO.inspect(mNid, label: "acq mNid")
    mPid = self()
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    IO.inspect(neighborMap, label: "acq my neighborMap")
    a = greatCommonPrefix(mNid,surrogateNid)
    maxLevel = length(a)
    IO.inspect(a,label: "acq a")
    candidateList = ackMulticastInBuildTable(surrogatePid,a,mNid,mPid,self())
    candidateMap = Map.new(candidateList)
    IO.inspect(candidateList,label: "candidateList")
    [neighborMap,neighbor] = buildTableFromList(candidateMap,maxLevel,neighborMap,neighbor,mNid)
    IO.inspect([neighborMap,neighbor],label: "new neighborMap and neighbor")
    IO.inspect(maxLevel,label: "maxLvl")
    temp = 
    if maxLevel != 0 do
      Enum.map(maxLevel..1,fn x-> 
        candidateMap = getNextList(candidateMap,x)
        buildTableFromList(candidateMap,x,neighborMap,neighbor,mNid)
      end)
    else
      Enum.map(maxLevel..1,fn x-> 
        candidateMap = getNextList(candidateMap,x)
        buildTableFromList(candidateMap,x,neighborMap,neighbor,mNid)
      end)
    end
    
    neighborMapTemp = Enum.map(temp,fn x -> Enum.at(x,0) end)
    neighborTemp = Enum.map(temp,fn x -> Enum.at(x,1) end)

    IO.inspect([neighborMapTemp,neighborTemp],label: "nMT,nT")

    neighborMap = Enum.slice(neighborMap,maxLevel..3)
    k = Enum.reverse(Enum.map(maxLevel-1..0,fn x-> Enum.at(Enum.at(neighborMapTemp,x),x) end))
    neighborMap = k ++ neighborMap
    neighbor = Map.new(List.flatten(Enum.map(neighborTemp, fn x-> Map.to_list(x) end)))
    list = List.replace_at(list,3,neighbor)
    List.replace_at(list,4,neighborMap)
  end

  def buildTableFromList(candidateMap,maxLevel,neighborMap,neighbor,_mNid) do
    IO.puts("buildTFList")
    IO.inspect(neighborMap,label: "my neighborMap at beginning")
    neighborMapAtLvl=Enum.at(neighborMap,maxLevel)
    candidateNid=Map.keys(candidateMap)
    IO.inspect(candidateMap,label: "candMap")
    digitMap = 
    Enum.map(candidateNid,fn x ->
      IO.inspect(x, label: "x")
      digit = elem(Integer.parse(String.at(x,maxLevel),16),0)
      {digit,x}
    end)
    digitMap = Map.new(List.flatten(digitMap))
    IO.inspect(digitMap)
    neighborMapAtLvl = 
    Enum.map(0..15,fn x ->
      if Enum.at(neighborMapAtLvl,x) == "NULL" && !is_nil(digitMap[x]) do
        digitMap[x]
      else
        Enum.at(neighborMapAtLvl,x)
      end
    end)
    IO.inspect(neighborMapAtLvl, label: "new neighborMapAtLvl")
    neighborMap=List.replace_at(neighborMap,maxLevel,neighborMapAtLvl)
    
    tempNeighbor = 
    Enum.map(digitMap,fn x->
      nid = elem(x,1)
      {nid,candidateMap[nid]}
    end)
    tempNeighbor = Map.new(List.flatten(tempNeighbor))
	  [neighborMap,Map.merge(neighbor,tempNeighbor)]
  end

  def getNextList(candidateMap,lvl) do
    nextListMap = 
    Enum.map(candidateMap,fn x->
      Map.to_list(getNextLvlNodes(elem(x,1),lvl))
    end)
    IO.inspect(nextListMap,label: "nextListMap")
    Map.new(List.flatten(nextListMap))
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

  def ackMulticast(surrogatePid, a, newNNid, newNPid) do
    GenServer.cast(surrogatePid,{:ackMulticast,a,newNNid,newNPid})
  end

  def ackMulticastInBuildTable(surrogatePid,a,newNNid,newNPid,fatherPid) do
    GenServer.call(surrogatePid,{:ackMulticastIBT,a,newNNid,newNPid,fatherPid})
  end

  def getNextLvlNodes(pid,lvl) do
    GenServer.call(pid, {:getNLNodes,lvl})
  end

  def getPrelimNeighborMap(surrogatePid) do
    GenServer.call(surrogatePid, :getPreNeiMap)
  end

  def acqPriSurrogate(initPid,srcNid,srcPid,lvl) do
    GenServer.call(initPid,{:acqPriSur,srcNid,srcPid,lvl})
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
    IO.puts("ack multicast")
    IO.inspect(list,label: "list(ack)")
    mNid = hd(list)
    lvl = length(a)
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    neighborAtLvl = Enum.at(neighborMap,lvl-1)

    #查看对应位置是不是hole
    a = greatCommonPrefix(mNid,newNNid)
    maxLevel = length(a)
    nextDigit = elem(Integer.parse(String.at(newNNid,maxLevel),16),0)
    neighborAtMaxLvl = Enum.at(neighborMap,maxLevel-1)
    neighborMap = 
    if Enum.at(neighborAtMaxLvl,nextDigit)=="NULL" do
      List.replace_at(neighborMap,lvl,List.replace_at(Enum.at(neighborMap,lvl),nextDigit,newNNid))
    else
      neighborMap
    end
    neighbor = 
    if Enum.at(neighborAtMaxLvl,nextDigit)=="NULL" do
      Map.put(neighbor,newNNid,newNPid)
    else
      neighbor
    end
    list = List.replace_at(list,4,neighborMap)
    list = List.replace_at(list,3,neighbor)
    IO.inspect(list,label: "neilist(ack)")
    IO.inspect(neighborAtLvl,label: "neineighborAtlvl(ack)")


    if Enum.find_value(neighborAtLvl,fn x -> x != "NULL"&& x !=mNid end) do
      Enum.map(0..15,fn x ->
        if Enum.at(neighborAtLvl,x) != "NULL" do
          IO.inspect(Enum.at(neighborAtLvl,x),label: "kk")
          TNode.ackMulticast(neighbor[Enum.at(neighborAtLvl,x)],Enum.slice(Enum.at(neighborAtLvl,x),0..lvl),newNPid,newNPid)
        end
      end)
    end
    
    IO.puts("ack over")
    {:noreply,list}
  end

  # def handle_cast({:routeToNode,nid,lvl,srcPid,numHop},list) do
  #   mNid = List.first(list)
  #   numHop = numHop + 1
  #   if mNid == nid do
  #     send :main, {:compareNumHop,numHop}
  #   else
  #     neighborMap = Enum.at(list,4)
  #     neighbor = Enum.at(list,3)
  #     nextN = nextHop(mNid,lvl,nid,neighborMap)
  #     IO.puts("routToNode")
  #     if nextN != mNid do
  #       TNode.routeToNode(neighbor[nextN],nid,lvl+1,srcPid,numHop)
  #     else
  #       IO.puts("error0,cannot find such node")
  #     end
  #     {:noreply,list}
  #   end
  # end

  # def handle_cast({:routeToObj,_pid,guid,lvl,srcPid},list) do
  #   objMap = Enum.at(list,2)
  #   if Map.has_key?(objMap,guid) do
  #     #send objMap[guid] to srcPid
  #   else
  #     mNid = List.first(list)
  #     neighborMap = Enum.at(list,4)
  #     neighbor = Enum.at(list,3)
  #     nextN = nextHop(mNid,lvl,guid,neighborMap)
  #     if nextN != mNid do
  #       TNode.routeToObj(neighbor[nextN],guid,lvl+1,srcPid)
  #     else
  #       IO.puts("error0,no such object")
  #     end
  #     {:noreply,list}
  #   end
  # end

  # def handle_cast({:publish,guid,aid,lvl},list) do
  #   objMap = Map.put(Enum.at(list,2),guid,aid)
  #   mNid = List.first(list)
  #   neighborMap = Enum.at(list,4)
  #   neighbor = Enum.at(list,3)
  #   nextN = nextHop(mNid,lvl,guid,neighborMap)
  #   if nextN != mNid do
  #     TNode.publishObj(neighbor[nextN],guid,aid,lvl+1)
  #   end
  #   {:noreply, List.replace_at(list,2,objMap)}
  # end

  def handle_call({:ackMulticastIBT,a,newNNid,newNPid,_fatherPid},_from,list) do
    mNid = hd(list)
    lvl = length(a)
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    neighborAtLvl = Enum.at(neighborMap,lvl)
    ###################################
    listTuple = [{mNid,self()}]
    
    IO.inspect(listTuple,label: "listTuple0")
    IO.inspect(neighborMap,label: "neighbormap")
    IO.inspect(neighbor,label: "neighbor")
    IO.inspect(neighborAtLvl,label: "neighborAL")

    temp = 
    if Enum.find_value(neighborAtLvl,fn x -> (x != "NULL")&&(x != mNid)&&(x != newNNid) end) do
      Enum.map(0..15,fn x ->
        IO.inspect(lvl,label: "have other candiate in lvl")
        if Enum.at(neighborAtLvl,x)!="NULL" do
          TNode.ackMulticastInBuildTable(neighbor[Enum.at(neighborAtLvl,x)],Enum.slice(Enum.at(neighborAtLvl,x),0..lvl),newNNid,newNPid,self())
        end
      end)
    else
      []
    end
    IO.inspect(temp, label: "temp")
    IO.puts("acq out")
    listTuple = listTuple++List.flatten(temp)
    IO.inspect(listTuple,label: "listTuple")
    
    #listMap = functionS(numChild,listMap)
    #send fatherPid,{:ack,listMap}
    {:reply,listTuple,list}
  end

  def handle_call({:acqPriSur,srcNid,srcPid,lvl},_from,list) do
    mNid = List.first(list)
    neighborMap = Enum.at(list,4)   ######
    neighbor = Enum.at(list,3)
    nextN = nextHop(mNid,lvl,srcNid,neighborMap)
    IO.inspect(nextN,label: "nextN")
    if nextN != mNid do
      [surrogateNid,surrogatePid] = TNode.acqPriSurrogate(neighbor[nextN],srcNid,srcPid,lvl+1)
      {:reply,[surrogateNid,surrogatePid],list}
    else
      IO.inspect("go back")
      {:reply,[mNid,self()],list}
    end
  end

  def handle_call(:getPreNeiMap, _from, list) do
    neighborMap = Enum.at(list,4)
    {:reply, neighborMap, list}
  end

  def handle_call({:getNLNodes,lvl}, _from, list) do
    neighbor = Enum.at(list,3)
    neighborNidAtLvl = Enum.at(Enum.at(list,4),lvl-1)
    nextListMap = Map.new(Enum.map(neighborNidAtLvl,fn x -> 
      {x,neighbor[x]}
    end))
    nextListMap = Map.drop(nextListMap,["NULL",hd(list)])
    IO.inspect(nextListMap, label: "handle_call nextListMap")
    {:reply, nextListMap, list}
  end

  def functionS(n,listMap) when n==0 do
		listMap
	end
	def functionS(n,listMap) do
		receive do
      {:ack,listMapBefore}->
        listMap = Map.merge(listMapBefore,listMap)
        functionS(n-1,listMap)
		after
			3->
				IO.inspect(n, label: "dead in ackMulticastIBT!")
		end
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
        allNeighbor = List.delete(Enum.uniq(allNeighbor),"NULL")
        IO.inspect(allNeighbor,label: "allNeighbor")
        Enum.min_by(allNeighbor,fn x -> abs(elem(Integer.parse(x,16),0)-elem(Integer.parse(matchID,16),0)) end)
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
