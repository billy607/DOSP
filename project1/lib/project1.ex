defmodule Project1 do
  def of([]) do
    [[]]
  end

  def of(list) do
    for h <- list, t <- of(list -- [h]), do: [h | t]
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
