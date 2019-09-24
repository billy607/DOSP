defmodule Pro2 do
	def main(nNum,topology,algorithm) do
		Process.register(self(),:main)
		case algorithm do
			"gossip"->Pro2.gossip(nNum,topology)
			"push_sum"->Pro2.push_sum(nNum,topology)
		end
		waitSignal(nNum)
	end 
	def waitSignal(n) when n==0 do
		IO.puts("finish")
	end
	def waitSignal(n) do
		IO.puts(n)
		receive do
			{:finish}->waitSignal(n-1)
		end
	end
	
#############################################algorithm
	def gossip(nNum,topology) do
		IO.puts("gossip")
		list=Enum.to_list 1..nNum
		plist=[]
		plist=plist++Enum.map(list,fn(x)->
			{:ok, pid}=Node.start_link(plist,0,0,0)
			pid
		end)
		Enum.map(plist,fn(x)->
			case topology do
				"full"->Node.update(x,full(x,plist))
				"line"->IO.puts(" ")
				"rand2D"->IO.puts(" ")
				"torus"->IO.puts(" ")
				"honeycomb"->IO.puts(" ")
				"ranhoneycomb"->IO.puts(" ")
			end
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
	def init(list) do
		{:ok,list}
	end
	def start_link(neighbor,s,w,times) do
		GenServer.start_link(__MODULE__,[neighbor,s,w,times])
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
	
	
	def handle_cast({:update,newneighbor},list) do
		neighbor=hd(list)++newneighbor
		list=List.replace_at(list,0,neighbor)
		{:noreply, list}
	end	
	def handle_cast({:update_minus,newneighbor},list) do
		neighbor=hd(list)--[newneighbor] 
		list=List.replace_at(list,0,neighbor)
		if Enum.empty?(neighbor) do 
			IO.inspect(self(), label: "done")
			send :main,{:finish}
			Process.exit(self(),:normal) 
		end
		{:noreply, list}
	end
	def handle_cast({:send},list) do
		#last=List.last(list)
		des=Enum.random(hd(list))
		Node.receive(des,"hello")
		Node.send(self())
		{:noreply, list}
	end
	def handle_cast({:receive, pid, message},list) do
		last=List.last(list)
		last=last+1
		#IO.puts(last)
		list=List.replace_at(list,3,last)
		if message=="hello" do
			if last==10 do
				#IO.inspect(hd(list)++self())
				IO.inspect(self(), label: "done")
				Enum.each(hd(list),fn(x)->Node.update_minus(x,self())end)
				send :main,{:finish}
				#IO.inspect("111111")
				Process.exit(pid,:normal)
			end
		end
		Node.send(pid)
		{:noreply, list}
	end
end