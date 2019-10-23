defmodule TNode do
  use GenServer
  def init(list) do
    {:ok,list}
  end

  #pid:当前节点ip地址
  #guid:文件编号
  #aid:存有文件的节点的ip地址
  #objectMap:文件编号->存有该文件的ip地址
  #neighbor:节点编号->节点ip地址
  #neighborMap:Tapestry的neighbor Map

  def start_link(nid,guid,objectMap,neighbor,neighborMap) do
    GenServer.start_link(__MODULE__,[nid,guid,objectMap,neighbor,neighborMap])
  end

  def routeToObj(pid,guid,lvl,srcPid) do
    GenServer.cast(pid,{:routeToObj,guid,lvl,srcPid})
  end

  def publishObj(pid,guid,aid,lvl) do
    GenServer.cast(pid,{:publish,guid,aid,lvl})
  end

  def receiveObjPID(pid) do
    GenServer.cast(pid,{:receivePID})
  end

  def handle_cast({:routeToObj,pid,guid,lvl,srcPid},list) do
    objMap = Enum.at(list,2)
    if Map.has_key?(objMap,guid) do
      #send objMap[guid] to srcPid
    else
      mNid = List.first(list)
      neighborMap = List.last(list)
      neighbor = Enum.at(list,3)
      nextN = nextHop(mNid,lvl,guid,neighborMap)
      if nextN != mNid do
        TNode.routeToObj(neighbor[nextN],guid,lvl+1,srcPid)
      else
        IO.puts("error0,no such object")
      end
    end

  end

  def handle_cast({:publish,guid,aid,lvl},list) do
    objMap = Map.put(Enum.at(list,2),guid,aid)
    mNid = List.first(list)
    neighborMap = List.last(list)
    neighbor = Enum.at(list,3)
    nextN = nextHop(mNid,lvl,guid,neighborMap)
    if nextN != mNid do
      TNode.publishObj(neighbor[nextN],guid,aid,lvl+1)
    end
    {:noreply, List.replace_at(list,2,objMap)}
  end

  def nextHop(mNid,lvl,guid,neighborMap) do
    if lvl>4 do
      mNid
    else
      d = elem(Integer.parse(String.at(guid,lvl-1),16),0)
      e = Enum.at(Enum.at(neighborMap,lvl-1),d-1)
      e = 
      if e == "NULL" do
        list = Enum.map(0..14,fn x -> Enum.at(Enum.at(neighborMap,lvl-1),rem(x+d+1,16)) end)
        hd(List.delete(Enum.uniq(list),"NULL"))
      else
        e
      end
      if e == mNid do
        nextHop(mNid,lvl+1,guid,neighborMap)
      else
        e
      end
    end
  end

  def handle_cast({:receivePID},list) do
    
  end

  def test(nNode,nReq) do
    IO.inspect({nNode,nReq},label: "test")
  end
end
