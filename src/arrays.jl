function iscyclic(a::Vector)
    for i=1:length(a)-1
      if a == circshift(a, i)
        return true
      end
    end
    # else
    return false
end
export iscyclic


function isunique(a)::Bool
    return length(a) == length(unique(a))
end
export isunique

function mapArray(arr::AbstractArray, low, high)
"""
  map array values to region [0,1] where:
  * arr<=low -> 0
  * arr>=high -> 1
  * arr∈[low,high] -> values are linearily mapped from within [low,high] to [0,1]

  * quick test:
  *   mapArray(rand(3,3,3),0.25,0.75)
"""
  _arr, _low, _high = promote(arr, low, high)
  _arr = clamp.(_arr, _low, _high)
  return (_arr-_low)/(_high-_low)
end
export mapArray
