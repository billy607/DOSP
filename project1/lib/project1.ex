defmodule Project1 do
def main do
	list=[1,2,3,4]
	len=length(list)
	list1=of(list,0)
	list1=Enum.map(list1,fn(x)->Enum.chunk_every(x,div(len,2)) end)
	list1=Enum.map(list1,fn(x)->
		Enum.map(x,fn(y)->(connect(y,1,0))
	end)
	end)
	list2=[]
	len1=length(list1)
	list1=duplicate(list1,list2,len1)
	IO.inspect(list1)
	length(list1)
end
#查找重复并删除
def duplicate(list1,list2,len1) when list1==[] do
	list2=ifnil(list2)
	list2
end

def duplicate(list1,list2,len1) do
	x=hd(list1)
	list2=list2++(Enum.map(list1--[x],fn(y)->
			if List.first(x)==List.last(y)&&List.last(x)==List.first(y) do x end end))
	duplicate(list1--[hd(list1)],list2,len1)
	
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
  
def of([],n) do
    [[]]
end

def of(list,n) do
    for h <- list, t <- of(list -- [h],n=n+1), do: [h | t]
end


end

defmodule Worker do
    def test1 do
        receive do
            {:get,n1,n2} -> IO.puts("#{n1},#{n2}")
        end
    end

    def caculate(n1,n2) do

    end
end

defmodule Boss do
    def mGet(n1,n2) when n1+10000>=n2 do
        #pid = self()
        actor = spawn(&Worker.test1/0)
        send(actor, {:get,n1,n2})
    end

    def mGet(n1,n2) do
        #pid = self()    #get self process id
        n3 = n1 + 10000
        actor = spawn(&Worker.test1/0)
        send(actor, {:get,n1,n3})
        n1 = n3
        mGet(n1,n2)
    end
end
