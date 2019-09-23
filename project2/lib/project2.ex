defmodule Pro2 do
	def main(nNum,topology,algorithm) do
		case algorithm do
			"gossip"->Pro2.gossip(nNum,topology)
			"push_sum"->Pro2.push_sum(nNum,topology)
		end
		:timer.sleep(5000)
	end 
#############################################algorithm
	def gossip(nNum,topology) do
		IO.puts("gossip")
		list=Enum.to_list 1..nNum
		plist=[]
		plist=plist++Enum.map(list,fn(x)->
			{:ok, pid}=Node.start_link(plist)
			pid
		end)
		Enum.map(plist,fn(x)->
			neighbor=full(x,plist)
			IO.inspect(neighbor)
			Node.update(x,neighbor)
		end)
		first=List.first(plist)
		Node.send(first)
	end
	def push_sum(nNum,topology) do
		IO.puts("push_sum")
	
	end
		
###########################################topology
	def full(pid,plist) do
		plist=plist--[pid]		
		plist++[0]
	end
	def line() do
	
	end
	def rand2D() do
	
	end
	def torus() do
	
	end
	def honeycomb() do
	
	end
	def ranhoneycomb() do
	
	end
end
##########################################genserver Node
defmodule Node do
	use GenServer
	def init(neighbor) do
		{:ok,neighbor}
	end
	def start_link(neighbor) do
		GenServer.start_link(__MODULE__,neighbor)
	end
	def update(pid,newneighbor) do
		GenServer.cast(pid, {:update, newneighbor})
	end
	def receive(pid,message) do
		GenServer.cast(pid, {:receive,pid, message})
	end
	def send(pid) do
		GenServer.cast(pid, {:send})
	end
	def update_minus(pid,newneighbor) do
		GenServer.cast(pid, {:update_minus,newneighbor})
	end
	
	
	def handle_cast({:update,newneighbor},neighbor) do
		neighbor=neighbor++newneighbor
		{:noreply, neighbor}
	end	
	def handle_cast({:update_minus,newneighbor},neighbor) do
		IO.puts("hi")
		neighbor=neighbor--[newneighbor] 
		if List.first(neighbor)==List.last(neighbor) do 
			IO.inspect(neighbor++self())
			Process.exit(self(),:normal) 
		end
		{:noreply, neighbor}
	end
	def handle_cast({:send},neighbor) do
		last=List.last(neighbor)
		des=Enum.random(neighbor--[last])
		Node.receive(des,"hello")
		:timer.sleep(10)
		Node.send(self())
		{:noreply, neighbor}
	end
	def handle_cast({:receive, pid, message},neighbor) do
		last=List.last(neighbor)
		last=last+1
		IO.puts(last)
		len=length(neighbor)-1
		neighbor=List.replace_at(neighbor,len,last)
		if message=="hello" do
			if last==10 do
				IO.inspect(neighbor++self())
				Enum.each(neighbor,fn(x)->Node.update_minus(self(),x)end)
				Process.exit(pid,:normal)
			end
		end
		Node.send(pid)
		{:noreply, neighbor}
	end
end