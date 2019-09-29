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
		case algorithm do
			"gossip"->
				Pro2.gossip(nNum,topology)
				waitSignal(nNum)
			"push_sum"->
				Pro2.push_sum(nNum,topology)
				waitPushSum()
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
				waitSignal(0)
		end
	end

	def waitPushSum() do
		receive do
			{:finish}->
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
        	{:ok, pid}=Node.start_link(plist,0,0,0)
        	pid
    	end)
		case topology do
			"full"->
				Enum.map(plist,fn(x)-> Node.update(x,Topology.full(x,plist)) end)
			"line"->
				#Enum.map(plist,fn(x)->IO.inspect(Topology.line(x,plist),label: "neighbor") end)
				Enum.map(plist,fn(x)-> Node.update(x,Topology.line(x,plist)) end)
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
						IO.puts("First node do not have neighbors")
						:timer.sleep(10)
						Process.exit(self(),:normal)
					end
					Node.update(Enum.at(plist,x-1),Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)) 
				end)
			"torus"->IO.puts(" ")
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
					Node.update(Enum.at(plist,x-1),Topology.honeycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
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
					Node.update(Enum.at(plist,x-1),Topology.randhoneycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
				end)
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
		case topology do
				"full"->
					Enum.map(plist,fn(x)-> Node.update(x,Topology.full(x,plist)) end)
				"line"->
					Enum.map(plist,fn(x)-> Node.update(x,Topology.line(x,plist)) end)
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
							IO.puts("First node do not have neighbors")
							:timer.sleep(10)
							Process.exit(self(),:normal)
						end
						Node.update(Enum.at(plist,x-1),Topology.rand2D(Enum.at(plist,x-1),x,coordinate,plist,nNum)) 
					end)
            	"torus"->IO.puts(" ")
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
						Node.update(Enum.at(plist,x-1),Topology.honeycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
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
						Node.update(Enum.at(plist,x-1),Topology.randhoneycomb(Enum.at(plist,x-1),x,coordinate,plist,nNum))
					end)
        end
    	first=List.first(plist)
    	Node.send_sum(first)
	end
end
