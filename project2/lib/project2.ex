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
			{:error0}->IO.puts("First node do not have neighbors")
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
		case topology do
			"full"->
				Enum.map(plist,fn(x)-> Node.update(x,Topology.full(x,plist)) end)
			"line"->IO.puts(" ")
			"rand2D"->
				coordinate=[]
				coordinate=coordinate++Enum.map(plist,fn(x)-> 				
					xvalue=Enum.random(0..1000)/1000 
					yvalue=Enum.random(0..1000)/1000 
					[xvalue,yvalue]
				end)
				Enum.map(1..nNum,fn(x)-> 
					neighbor=Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)
					if x==1&&Enum.empty?(neighbor) do
						send :main,{:error0}
						:timer.sleep(10)
						Process.exit(self(),:kill)
					end
					Node.update(Enum.at(plist,x-1),Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)) 
				end)
			"torus"->IO.puts(" ")
			"honeycomb"->IO.puts(" ")
			"ranhoneycomb"->IO.puts(" ")
		end  	
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
            	"full"->Node.update(x,Topology.full(x,plist))
            	"line"->IO.puts(" ")
            	"rand2D"->
					coordinate=[]
					coordinate=coordinate++Enum.map(plist,fn(x)-> 				
						xvalue=Enum.random(0..1000)/1000 
						yvalue=Enum.random(0..1000)/1000 
						[xvalue,yvalue]
					end)
					Enum.map(1..nNum,fn(x)-> 
						neighbor=Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)
						if x==1&&Enum.empty?(neighbor) do
							send :main,{:error0}
							:timer.sleep(10)
							Process.exit(self(),:kill)
						end
						Node.update(Enum.at(plist,x-1),Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)) 
					end)
            	"torus"->IO.puts(" ")
            	"honeycomb"->IO.puts(" ")
            	"ranhoneycomb"->IO.puts(" ")
        	end
    	end)
    	first=List.first(plist)
    	Node.send_sum(first)
	end
end
