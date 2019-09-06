defmodule Worker do
    def test do
		receive do
			{:get,n1,n2} ->
				list = []
				res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
				if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
			{:last,n1,n2,caller} -> 
				list = []
				res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
				if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
				send caller,{:finish}
        end
    end

	def caculate do
		receive do
			{:get,n1,n2} ->
				list = []
				res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
				if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
			{:last,n1,n2,caller} -> 
				list = []
				res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
				if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
				send caller,{:finish}
		end
	end

	def caRange(n1,n2) do
		list = []
		res = Enum.filter(Enum.map(n1..n2,fn(x)->list ++ findFangs(x) end), &!is_nil(&1))
		if res != [] , do: Enum.each(res,fn(x)->IO.puts(Enum.join(x," ")) end)
	end
	
	def findFangs(number) do
	list=split(number,[])
	len=length(list)
	list1=of(list)
	list1=Enum.map(list1,fn(x)->Enum.chunk_every(x,div(len,2)) end)
	list1=Enum.map(list1,fn(x)->
		Enum.map(x,fn(y)->(connect(y,1,0))
	end)
	end)
#	list2=[]
#	len1=length(list1)
#	list1=duplicate(list1,list2,len1)
#	IO.inspect(list1)
#	length(list1)
	isVamp(list1,number)
end

def isVamp(list,number) do
	list1=Enum.map(list,fn(x)->
		if List.first(x)*List.last(x) == number&&(rem(List.first(x),10)!=0||rem(List.last(x),10)!=0) do x end
	end)
	list1=Enum.filter(list1, & !is_nil(&1))
	list1=duplicate(Enum.uniq(list1),[])
	if !Enum.empty?(list1) do
		List.flatten([number]++List.flatten(list1))
	end
end

#查找重复并删除
def duplicate(list1,list2) when list1==[] do
	list2=ifnil(list2)
	list2
end

def duplicate(list1,list2) do
	x=hd(list1)
	list2=list2++(Enum.map(list1--[x],fn(y)->
			if List.first(x)==List.last(y)&&List.last(x)==List.first(y) do x end end))
	duplicate(list1--[hd(list1)],list2)
	
end
#删除空值

def ifnil(list) do
    answer=Enum.any?(list,fn(x)->x==nil end)
	if answer==true do
		list=List.delete(list,nil)
		ifnil(list)
	else
		list
	end
	
end

#将数字拆开
def split(num,list) when num == 0 do
	Enum.reverse(list)
end

def split(num,list) do
	list = list ++ [rem(num,10)]
	split(div(num,10),list)
end

#将数字连接起来
def connect(list,n,num) when list==[]do
	num
end

def connect(list,n,num) do
	len=length(list)
	n=n*(:math.pow(10,len-1) |> round)
	num=hd(list)*n+num
#	IO.puts(num)
	n=1
	list=list--[hd(list)]
	connect(list,n,num)
end

#find all permutations  
def of([]) do
    [[]]
end

def of(list) do
    for h <- list, t <- of(list -- [h]), do: [h | t]
end
end

defmodule Boss do
    def mGet(n1,n2) when n1+9999>=n2 do
        pid = self()
        actor = spawn(&Worker.test/0)
		send(actor, {:last,n1,n2,pid})
		IO.puts("finish")
		waitSignal()
    end

	def mGet(n1,n2) do
        n3 = n1 + 9999
        actor = spawn(&Worker.test/0)
        send(actor, {:get,n1,n3})
        n1 = n3 + 1
        mGet(n1,n2)
	end
	
	def waitSignal do
		receive do
			{:finish} -> true
		end
	end
end