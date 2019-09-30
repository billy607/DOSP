defmodule Topology do
    def full(pid,plist) do
        plist--[pid]
    end
	def line(pid,plist) do
		index = Enum.find_index(plist,fn x -> x == pid end)
        if index == 0 do
            [Enum.at(plist,index+1)]
        else 
            if index == length(plist)-1 do
                [Enum.at(plist,index-1)]
            else
                [Enum.at(plist,index-1),Enum.at(plist,index+1)]
            end
        end
    end
    def rand2D(pid,pnum,coordinate,plist,nNum) do
		list=Enum.to_list 1..nNum
		c=Enum.at(coordinate,pnum-1)
		cx=List.first(c)
		cy=List.last(c)
		plist=plist--Enum.map(list,fn(x)->
			c=Enum.at(coordinate,x-1)
			p=Enum.at(plist,x-1)
			dx=List.first(c)-cx
			dy=List.last(c)-cy
			if :math.pow(dx,2)+:math.pow(dy,2)>0.01 do
				p
			end	
		end)
		#IO.inspect([pid,plist--[pid]],label: "pid and neighbor")
		plist--[pid]
    end
	def torus(pid,plist) do
		n = trunc(:math.ceil(:math.pow(length(plist),1/3)))
		#IO.inspect(n, label: "length")
		index = Enum.find_index(plist,fn x -> x == pid end)
		#IO.inspect(index, label: "index")
		neighbor = []
		neighbor = neighbor ++ if rem(index,n) == 0 ,do: [Enum.at(plist,index + n - 1)], else: [Enum.at(plist,index - 1)]
		neighbor = neighbor ++ if rem(index,n) == n-1 ,do: [Enum.at(plist,index - (n - 1))], else: [Enum.at(plist,index + 1)]
		neighbor = neighbor ++ if index <= (n*n - 1) ,do: [Enum.at(plist,index + n*n*(n-1))], else: [Enum.at(plist,index - n*n)]
        neighbor = neighbor ++ if index >= n*n*(n-1) ,do: [Enum.at(plist,index - n*n*(n-1))], else: [Enum.at(plist,index + n*n)]
		neighbor = neighbor ++ if rem(index,n*n) < n ,do: [Enum.at(plist,index + n*(n-1))], else: [Enum.at(plist,index - n)]
		neighbor = neighbor ++ if rem(index,n*n) >= n*(n-1) ,do: [Enum.at(plist,index - n*(n-1))], else: [Enum.at(plist,index + n)]
		neighbor = Enum.uniq(Enum.filter(neighbor--[pid], fn x -> !is_nil(x) end))
		#IO.inspect(neighbor,label: "myneighbor")
    end
    def honeycomb(pid,pnum,coordinate,plist,nNum) do
		list=Enum.to_list 1..nNum
		c=Enum.at(coordinate,pnum-1)
		cx=List.first(c)
		cy=List.last(c)
		plist=plist--Enum.map(list,fn(x)->
			c=Enum.at(coordinate,x-1)
			p=Enum.at(plist,x-1)
			dx=List.first(c)-cx
			dy=List.last(c)-cy
			if round(:math.pow(dx,2)+:math.pow(dy,2))>4 do
				p
			end	
		end)
		#IO.inspect([pid,plist--[pid]],label: "pid and neighbor")
		plist--[pid]
    end
    def randhoneycomb(pid,pnum,coordinate,plist,nNum) do
		list=Enum.to_list 1..nNum
		c=Enum.at(coordinate,pnum-1)
		cx=List.first(c)
		cy=List.last(c)
		l=[]
		l=l++Enum.map(list,fn(x)->
			c=Enum.at(coordinate,x-1)
			p=Enum.at(plist,x-1)
			dx=List.first(c)-cx
			dy=List.last(c)-cy
			if round(:math.pow(dx,2)+:math.pow(dy,2))>4 do
				p
			end	
		end)
		l=Enum.filter(l,fn(x)->!is_nil(x) end)
		node=
			if !Enum.empty?(l) do Enum.random(l) end
		#IO.inspect(node,label: "node")
		plist=plist--l
		plist=
			if !is_nil(node) do 
				plist++[node] else plist end
		#IO.inspect([pid,plist--[pid]],label: "pid and neighbor")
		plist--[pid]
    end
end