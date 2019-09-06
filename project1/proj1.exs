args = System.argv()
n1 = String.to_integer(Enum.at(args,0))
n2 = String.to_integer(Enum.at(args,1))
range1 = div(n1,1000)
range2 = div(n2,1000)
if n1<10 do
    if n2<10 do
    else 
        n1=10
        Boss.mGet(n1,n2,range2-range1-1)
    end
else
    if rem(n1,1000) != 0 do
        Boss.mGet(n1,n2,range2-range1-1)
    else
        Boss.mGet(n1,n2,range2-range1)
    end
end
