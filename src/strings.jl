function iscyclic(s::String)
    a = [c for c in s]
    return iscyclic(a)
end
export iscyclic


import Base.circshift
function circshift(s::String, shifts)
    a = [c for c in s]
    return join(circshift(a, shifts))
end
