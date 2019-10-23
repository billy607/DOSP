defmodule TNode do
  use GenServer
  def init(list) do
    (:ok,list)
  end

  def start_link(nid,guid,objectMap,neighborMap) do
    GenServer.start_link(__MODULE__,[nid,guid,objectMap,neighbor,neighborMap])
  end

  def publishObj(guid,pid,lvl) do
    GenServer.cast(pid,{:publish,guid,pid,lvl})
  end

  def handle_cast({:publish,guid,pid,lvl},list) do
    #if this is root
    objMap = Map.put(Enum.at(list,2),String.to_atom(guid),pid)
    if guid == Enum.at(list,1)||lvl > 4 do
      {:noreply,List.replace_at(list,2,objMap)}
    end
    neighborMap = List.last(list)
    
    #digit = String.at(guid,lvl-1)   #the vale of guid at level lvl
    #nextN = Enum.at(Enum.at(neighborMap,lvl-1),elem(Integer.parse(digit,16),0)-1)
    #if nextN == "NULL" do
    #  allNeighbor = Enum.at(neighborMap,lvl-1)
    #  nextN = Enum.min_by(allNeighbor,fn x -> abs(elem(Integer.parse(x,16),0)-elem(Integer.parse(guid,16),0)) end)
    #end
    #lvl = lvl + 1

  end

  def test(nNode,nReq) do
    IO.inspect({nNode,nReq},label: "test")
  end
end
