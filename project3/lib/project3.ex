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
  def start_link(nid,neighbor,neighborMap,init,allnode) do
    GenServer.start_link(__MODULE__,[nid,neighbor,neighborMap,init,allnode])
  end
  
  def init(list) do
    neighborMap = Enum.at(list,2)
	mPid = self()
    sha1 = :crypto.hash(:sha, Kernel.inspect(mPid)) |> Base.encode16
    mNid = String.slice(sha1,0..3)
    d1 = elem(Integer.parse(String.at(mNid,0),16),0)
    d2 = elem(Integer.parse(String.at(mNid,1),16),0)
    d3 = elem(Integer.parse(String.at(mNid,2),16),0)
    d4 = elem(Integer.parse(String.at(mNid,3),16),0)
    temp = [d1,d2,d3,d4]	
    neighborMap = Enum.map(0..3,fn x -> List.replace_at(Enum.at(neighborMap,x),Enum.at(temp,x),mNid) end)  #将自己添加到neighbormap中
	list=List.replace_at(list,2,neighborMap)
    if Enum.at(list,5) do
      Process.register(mPid,:initPid)
      {:ok,List.replace_at(list,0,mNid)}
    else
      list = List.replace_at(list,0,mNid)

      initPid = Process.whereis(:initPid)
      {:ok,list}
    end
  end

  def acqNeighborMap(surrogateNid,surrogatePid,list) do
    mNid = hd(list)
    mPid = self()
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    a = greatCommonPrefix(mNid,surrogateNid)
    maxLevel = length(a)
    candidateList = ackMulticastInBuildTable(surrogatePid,a,mNid,mPid,self())
    neighborMap = buildTableFromList(candidateList,maxLevel,neighborMap,neighbor,mNid) 
    #neighborMap = List.replace_at(neighborMap,maxLevel-1,neighborMapAtlvl)
    #########
    temp = 
    Enum.map(maxLevel-1..0,fn x->
      list = getNextList()
      #buildTableFromList(list,x)
    end)
  end

  def buildTableFromList(candidateList,maxLevel,neighborMap,neighbor,mNid) do
	
  end

  def getNextList do
    
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

  def update(pid,list) do
	GenServer.cast(pid,{:update,list})
  end
  
  def insert(pid) do
	GenServer.cast(pid,{:insert})
  end

  def ackMulticastInBuildTable(surrogatePid,a,newNNid,newNPid,fatherPid) do
    GenServer.cast(surrogatePid,{:ackMulticastIBT,a,newNNid,newNPid})
  end

  def ackMulticast(surrogatePid, a, newNNid, newNPid) do
    GenServer.cast(surrogatePid,{:ackMulticast,a,newNNid,newNPid})
  end

  def getPrelimNeighborMap(surrogatePid) do
    GenServer.call(surrogatePid, :getPreNeiMap)
  end

  def acqPriSurrogate(initPid,srcNid,srcPid,lvl) do
    GenServer.cast(initPid,{:acqPriSur,srcNid,srcPid,lvl})
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
  
  def handle_cast({:update,allnodes},list) do
	send :main, {:updatefinish}
	{:noreply,List.replace_at(list,4,allnodes)}
  end
  
  def handle_cast({:insert},list) do
	mNid=Enum.at(list,0)
	#IO.puts(mNid)
	#neighbor=Enum.at(list,1)
	#neighborMap=Enum.at(list,2)
	allnodes=Enum.at(list,4)
	allnodesnid=Map.keys(allnodes)
	allnodespid=Map.values(allnodes)
	neighborMap=[]
	allnodesnid=allnodesnid--[mNid]
	#IO.puts("hello")
	candidateline1=Enum.map(1..16,fn(digit)->
		node=Enum.find(allnodesnid,fn(node)-> elem(Integer.parse(String.at(node,0),16),0)==digit-1 end)
		if is_nil(node)==false do
			node
		else 
			"NULL"
		end
	end)
	candidateline2=Enum.map(1..16,fn(digit)->
		n=String.slice(mNid,0..0)
		node=Enum.find(allnodesnid,fn(node)-> elem(Integer.parse(String.at(node,1),16),0)==digit-1&&String.slice(node,0..0)==n end)
		if is_nil(node)==false do
			node
		else 
			"NULL"
		end
	end)
	candidateline3=Enum.map(1..16,fn(digit)->
		n=String.slice(mNid,0..1)
		node=Enum.find(allnodesnid,fn(node)-> elem(Integer.parse(String.at(node,2),16),0)==digit-1&&String.slice(node,0..1)==n end)
		if is_nil(node)==false do
			node
		else 
			"NULL"
		end
	end)
	candidateline4=Enum.map(1..16,fn(digit)->
		n=String.slice(mNid,0..2)
		node=Enum.find(allnodesnid,fn(node)-> elem(Integer.parse(String.at(node,3),16),0)==digit-1&&String.slice(node,0..2)==n end)
		if is_nil(node)==false do
			node
		else 
			"NULL"
		end
	end)
	neighborMap=[candidateline1,candidateline2,candidateline3,candidateline4]
		
	
    d1 = elem(Integer.parse(String.at(mNid,0),16),0)
    d2 = elem(Integer.parse(String.at(mNid,1),16),0)
    d3 = elem(Integer.parse(String.at(mNid,2),16),0)
    d4 = elem(Integer.parse(String.at(mNid,3),16),0)
	temp = [d1,d2,d3,d4]
	neighborMap = Enum.map(0..3,fn x -> List.replace_at(Enum.at(neighborMap,x),Enum.at(temp,x),mNid) end)
	nei=List.flatten(Enum.map(1..4,fn(lvl)->
		Enum.map(Enum.at(neighborMap,lvl-1),fn(x)->
			pid=if x != "NULL" do
				elem(Map.fetch(allnodes,x),1)
			end
			if is_nil(pid)==false do
			{x,pid}
			end
		end)
	end))
	nei=List.delete(Enum.uniq(nei),nil)
	neighbor=Map.new(nei)
	list=List.replace_at(list,2,neighborMap)
	list=List.replace_at(list,1,neighbor)
	#IO.inspect(neighborMap,label: mNid)
	#IO.inspect(mNid)
	{:noreply,list}
  end



  def handle_cast({:ackMulticast,a,newNNid,newNPid},list) do
    mNid = hd(list)
    lvl = length(a)
    nextDigit = elem(Integer.parse(String.at(newNNid,lvl),16),0)
    neighbor = Enum.at(list,3)
    neighborMap = Enum.at(list,4)
    neighborAtLvl = Enum.at(neighborMap,lvl-1)
    if Enum.find_value(neighborAtLvl,fn x -> x != "NULL"&& x !=mNid end) do
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
    if Enum.find_value(neighborAtLvl,fn x -> (x != "NULL")&&(x != mNid) end) do
      Enum.map(0..15,fn x ->
        if Enum.at(neighborAtLvl,x)!="NULL" do
          TNode.ackMulticastInBuildTable(neighbor[Enum.at(neighborAtLvl,x)],Enum.slice(Enum.at(neighborAtLvl,x),0..lvl),newNPid,newNPid,self())
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

  def handle_cast({:acqPriSur,srcNid,srcPid,lvl},list) do
    mNid = List.first(list)
    neighborMap = Enum.at(list,4)   ######
    neighbor = Enum.at(list,3)
    nextN = nextHop(mNid,lvl,srcNid,neighborMap)
    if nextN != mNid do
      TNode.acqPriSurrogate(neighbor[nextN],srcNid,lvl+1,srcPid)
    else
      send srcPid,{:surrogate,mNid,self()}
    end
    {:noreply,list}
  end

  def handle_cast({:routeToNode,nid,lvl,srcPid,numHop},list) do
    mNid = List.first(list)
    if mNid == nid do
      send :main, {:compareNumHop,numHop}
	  {:noreply,list}
    else
	  numHop = numHop + 1
      neighborMap = Enum.at(list,2)
      neighbor = Enum.at(list,1)
      nextN = nextHop(mNid,lvl,nid,neighborMap)
      if nextN != mNid do
        TNode.routeToNode(neighbor[nextN],nid,lvl+1,srcPid,numHop)
      else
		IO.inspect(neighborMap)
		IO.inspect(nid, label: mNid)
        IO.puts("error0,cannot find such node")
      end
      {:noreply,list}
    end
  end

  def handle_cast({:routeToObj,_pid,guid,lvl,srcPid},list) do
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

  def handle_call(:getPreNeiMap, _from, list) do
    neighborMap = Enum.at(list,4)
    {:reply, neighborMap, list}
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

  def nextHop(mNid,lvl,matchID,neighborMap) do    #matchID 需要查找的目标ID
    if lvl>4 do
      mNid
    else
      d = elem(Integer.parse(String.at(matchID,lvl-1),16),0)
      e = Enum.at(Enum.at(neighborMap,lvl-1),d)
      e = 
      if e == "NULL" do
        #list = Enum.map(0..14,fn x -> Enum.at(Enum.at(neighborMap,lvl-1),rem(x+d+1,16)) end)
        #hd(List.delete(Enum.uniq(list),"NULL"))
        allNeighbor = Enum.at(neighborMap,lvl-1)
		allNeighbor=List.delete(Enum.uniq(allNeighbor),"NULL")
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
