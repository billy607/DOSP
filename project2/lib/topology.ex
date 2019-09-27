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
		IO.inspect([pid,plist--[pid]],label: "pid and neighbor")
		plist--[pid]
    end
    def torus() do
    
    end
    def honeycomb() do
    
    end
    def ranhoneycomb() do
    
    end
end