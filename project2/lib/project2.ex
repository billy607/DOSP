defmodule Pro2 do
	def main(args) do
		nNum = Enum.at(args,0) |> String.to_integer()
		if nNum>1 do 
			topology  = Enum.at(args,1)
			algorithm = Enum.at(args,2)
			Process.register(self(),:main)
			case algorithm do
				"gossip"->
					Pro2.gossip(nNum,topology)
					{time,_} = :timer.tc(fn -> waitSignal(nNum) end)
					IO.puts "Actual Time: #{time}"
					:timer.sleep(10)
				"push_sum"->
					Pro2.push_sum(nNum,topology)
					{time,_} = :timer.tc(fn -> waitPushSum() end)
					IO.puts "Actual Time: #{time}"
					:timer.sleep(10)
			end
		else
			IO.puts("number should large than 1")
		end
	end 

	def start(nNum,topology,algorithm) do
		Process.register(self(),:main)
		case algorithm do
			"gossip"->
				Pro2.gossip(nNum,topology)
				{time,_} = :timer.tc(fn -> waitSignal(nNum) end)
				IO.puts "Actual Time: #{time}"
				:timer.sleep(10)
			"push_sum"->
				Pro2.push_sum(nNum,topology)
				{time,_} = :timer.tc(fn -> waitPushSum() end)
				IO.puts "Actual Time: #{time}"
				:timer.sleep(10)
		end
		
	end
	
	def waitSignal(n) when n==0 do
		:timer.sleep(10)
		IO.puts("finish")
	end
	def waitSignal(n) do
		receive do
			{:finish}->waitSignal(n-1)
		after
			3000->
				IO.inspect(n, label: "Unreached node number")
				waitSignal(0)
		end
	end

	def waitPushSum() do
		receive do
			{:finish1}->
				:timer.sleep(10)
				IO.puts("finish")
		end
	end

	#############################################algorithm
	def gossip(nNum,topology) do
    	IO.puts("gossip")
    	list=Enum.to_list 1..nNum
    	plist=[]
    	plist=plist++Enum.map(list,fn(_x)->
        	{:ok, pid}=MyNode.start_link(plist,0,0,0)
        	pid
    	end)
		case topology do
			"full"->
				Enum.map(plist,fn(x)-> MyNode.update(x,Topology.full(x,plist)) end)
			"line"->
				Enum.map(plist,fn(x)-> MyNode.update(x,Topology.line(x,plist)) end)
			"rand2D"->
				coordinate=[]
				coordinate=coordinate++Enum.map(plist,fn(_x)-> 				
					xvalue=Enum.random(0..1000)/1000 
					yvalue=Enum.random(0..1000)/1000 
					[xvalue,yvalue]
				end)
				Enum.map(1..nNum,fn(x)-> 
					neighbor=Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)
					if x==1&&Enum.empty?(neighbor) do
						IO.puts("First node do not have neighbors")
						:timer.sleep(10)
						Process.exit(self(),:normal)
					end
					MyNode.update(Enum.at(plist,x-1),Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)) 
				end)
			"torus"->
				#IO.inspect(plist,label: "plist")
				Enum.map(plist,fn(x)-> MyNode.update(x,Topology.torus(x,plist)) end)
			"honeycomb"->
				coordinate=[]
				coordinate=coordinate++Enum.map(1..nNum,fn(x)-> 
					x=x-1
					line=div(x,6)
					r=rem(x,6)
					num=div(r,2)
					yvalue=
						if r==1||r==2||r==5 do (2*line+1)*:math.sqrt(3) else 2*line*:math.sqrt(3) end
					xvalue=
						#if rem(num,2)==0 do 3*num else 3*num+1 end
						num+r
					[xvalue,yvalue]
				end)
				Enum.map(1..nNum,fn(x)-> 
					MyNode.update(Enum.at(plist,x-1),Topology.honeycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
				end)
			"randhoneycomb"->
				coordinate=[]
				coordinate=coordinate++Enum.map(1..nNum,fn(x)-> 
					x=x-1
					line=div(x,6)
					r=rem(x,6)
					num=div(r,2)
					yvalue=
						if r==1||r==2||r==5 do (2*line+1)*:math.sqrt(3) else 2*line*:math.sqrt(3) end
					xvalue=
						#if rem(num,2)==0 do 3*num else 3*num+1 end
						num+r
					[xvalue,yvalue]
				end)
				Enum.map(1..nNum,fn(x)-> 
					MyNode.update(Enum.at(plist,x-1),Topology.randhoneycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
				end)
		end  	
    	first=List.first(plist)
    	MyNode.send(first)
	end
	def push_sum(nNum,topology) do
    	IO.puts("push_sum")
    	list=Enum.to_list 1..nNum
    	plist=[]
    	plist=plist++Enum.map(list,fn(x)->
        	{:ok, pid}=MyNode.start_link(plist,x,1,0)
        	pid
    	end)
		case topology do
				"full"->
					Enum.map(plist,fn(x)-> MyNode.update(x,Topology.full(x,plist)) end)
				"line"->
					Enum.map(plist,fn(x)-> MyNode.update(x,Topology.line(x,plist)) end)
            	"rand2D"->
					coordinate=[]
					coordinate=coordinate++Enum.map(plist,fn(_x)-> 				
						xvalue=Enum.random(0..1000)/1000 
						yvalue=Enum.random(0..1000)/1000 
						[xvalue,yvalue]
					end)
					Enum.map(1..nNum,fn(x)-> 
						neighbor=Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)
						if x==1&&Enum.empty?(neighbor) do
							IO.puts("First node do not have neighbors")
							:timer.sleep(10)
							Process.exit(self(),:normal)
						end
						MyNode.update(Enum.at(plist,x-1),neighbor) 
					end)
				"torus"->
					#IO.inspect(plist, label: "plist")
					Enum.map(plist,fn(x)-> MyNode.update(x,Topology.torus(x,plist)) end)
            	"honeycomb"->
					coordinate=[]
					coordinate=coordinate++Enum.map(1..nNum,fn(x)-> 
						x=x-1
						line=div(x,6)
						r=rem(x,6)
						num=div(r,2)
						yvalue=
							if r==1||r==2||r==5 do (2*line+1)*:math.sqrt(3) else 2*line*:math.sqrt(3) end
						xvalue=
							#if rem(num,2)==0 do 3*num else 3*num+1 end
							num+r
						[xvalue,yvalue]
					end)
					Enum.map(1..nNum,fn(x)-> 
						MyNode.update(Enum.at(plist,x-1),Topology.honeycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
					end)
            	"randhoneycomb"->
					coordinate=[]
					coordinate=coordinate++Enum.map(1..nNum,fn(x)-> 
						x=x-1
						line=div(x,6)
						r=rem(x,6)
						num=div(r,2)
						yvalue=
							if r==1||r==2||r==5 do (2*line+1)*:math.sqrt(3) else 2*line*:math.sqrt(3) end
						xvalue=
							#if rem(num,2)==0 do 3*num else 3*num+1 end
							num+r
						[xvalue,yvalue]
					end)
					Enum.map(1..nNum,fn(x)-> 
						MyNode.update(Enum.at(plist,x-1),Topology.randhoneycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
					end)
        end
    	first=List.first(plist)
    	MyNode.send_sum(first)
	end
end
