defmodule TNode do
  use GenServer
  def init(list) do
    (:ok,list)
  end

  def start_link(x,y,nid,guid,neighbor) do
    GenServer.start_link(__MODULE__,[x,y,nid,guid,neighbor])
  end

  def publishObj(guid,pid,lvl) do
    GenServer.cast(pid,{:publish,guid,pid,lvl})
  end

  def handle_cast({:publish,guid,pid,lvl},list) do
    neighbor = List.last(list)
    digit = String.at(guid,lvl-1)   #the vale of guid at level lvl-1
    
  end

  def test(nNode,nReq) do
    IO.inspect({nNode,nReq},label: "test")
  end
end
