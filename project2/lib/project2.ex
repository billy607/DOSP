defmodule Pro2 do
	def main(args) do
		nNum = Enum.at(args,0) |> String.to_integer()
		topology  = Enum.at(args,1)
		algorithm = Enum.at(args,2)
		Process.register(self(),:main)
		case algorithm do
			"gossip"->Pro2.gossip(nNum,topology)
			"push_sum"->Pro2.push_sum(nNum,topology)
		end
		waitSignal(1)
	end 

	def start(nNum,topology,algorithm) do
		Process.register(self(),:main)
		n = 
			case algorithm do
				"gossip"->
					Pro2.gossip(nNum,topology)
					nNum
				"push_sum"->
					Pro2.push_sum(nNum,topology)
					1
			end
		waitSignal(n)
	end
	
	def waitSignal(n) when n==0 do
		:timer.sleep(10)
		IO.puts("finish")
	end
	def waitSignal(n) do
		IO.puts(n)
		receive do
			{:finish}->waitSignal(n-1)
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
	def receive_sum(pid,s,w) do
		GenServer.cast(pid, {:receive_sum,s,w})
	end
	def send(pid) do
		GenServer.cast(pid, {:send})
	end
	def send_sum(pid) do
		GenServer.cast(pid, {:send_sum})
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
			IO.inspect(self(), label: "done_no_neighbor")
			Process.exit(self(),:normal) 
		end
		{:noreply, list}
	end
	def handle_cast({:send},list) do
		des=Enum.random(hd(list))
		Node.receive(des,"hello")
		:timer.sleep(10)
		Node.send(self())
		{:noreply, list}
	end
	def handle_cast({:send_sum}, list) do
		s=Enum.at(list,1)
		w=Enum.at(list,2)
		des=Enum.random(hd(list))
		Node.receive_sum(des,s/2,w/2)
		list=List.replace_at(list,1,s/2)
		list=List.replace_at(list,2,w/2)
		:timer.sleep(1)
		Node.send_sum(self())
		{:noreply, list}
	end
	def handle_cast({:receive, pid, message},list) do
		send :main,{:finish}
		IO.inspect(self(),label: "receive")
		last=List.last(list)
		last=last+1
		list=List.replace_at(list,3,last)
		if message=="hello" do
			if last==10 do
				IO.inspect(self(), label: "done_heard_10")
				Enum.each(hd(list),fn(x)->Node.update_minus(x,self())end)
				Process.exit(pid,:normal)
			end
		end
		Node.send(pid)
		{:noreply, list}
	end
	def handle_cast({:receive_sum,s,w},[neighbor,olds,oldw,last]) do
		#last=List.last(list)
		#olds=Enum.at(list,1)
		#oldw=Enum.at(list,2)
		s=s+olds
		w=w+oldw
		IO.inspect([self(),s,w,s/w],label: "pid,s,w,s/w")
		#list=List.replace_at(list,1,s)
		#list=List.replace_at(list,2,w)
		minus=abs(s/w-olds/oldw)
		last=
			if minus<=:math.pow(10,-10) do 
				#last=last+1
				#list=List.replace_at(list,3,last) 
				if last+1==3 do
					IO.inspect(self(), label: "done with no change")
					Enum.each(neighbor,fn(x)->Node.update_minus(x,self())end)
					send :main,{:finish}
					Process.exit(self(),:normal)
				end
				last+1
			else
				#List.replace_at(list,3,0)
				0
			end
		Node.send_sum(self())
		{:noreply, [neighbor,s,w,last]}
	end
end
	
#############################################algorithm
	def gossip(nNum,topology) do
		IO.puts("gossip")
		list=Enum.to_list 1..nNum
		plist=[]
		plist=plist++Enum.map(list,fn(_x)->
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
		list=Enum.to_list 1..nNum
		plist=[]
		plist=plist++Enum.map(list,fn(x)->
			IO.inspect(x,label: "aaa")
			{:ok, pid}=Node.start_link(plist,x,1,0)
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
		Node.send_sum(first)
	end
		
###########################################topology
	def full(pid,plist) do
		plist--[pid]
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
