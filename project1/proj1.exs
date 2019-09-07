defmodule Wait do
    def waitSignal do
		receive do
			{:finish} -> true
    	end
    end
end

args = System.argv()
n1 = String.to_integer(Enum.at(args,0))
n2 = String.to_integer(Enum.at(args,1))
range1 = div(n1,1000)
range2 = div(n2,1000)
pid = self()
if n1<10 do
    if n2<10 do
    else 
        n1=10
		Boss.start_link(range2-range1,pid,n1,n2)
    end
else
	if rem(n1,1000) != 0 do
		Boss.start_link(range2-range1,pid,n1,n2)
	else
		Boss.start_link(range2-range1+1,pid,n1,n2)
    end
end
Wait.waitSignal
