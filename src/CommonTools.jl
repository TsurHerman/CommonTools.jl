module CommonTools

import ArgParse
import GLVisualize
import Rotations
import NearestNeighbors
import Parameters
import Reactive
import NamedTuples
import Images
import BenchmarkTools
import MeshIO
import FileIO
import DataStructures
import ColorTypes
import Optim
import GeometryTypes
import PyPlot
import LsqFit


# !isdefined(:my_full_name) && (my_full_name = @__FILE__)
# includeallafiles(my_full_name)

include("arrays.jl")
include("filesystem.jl")
include("ini.jl")
include("FPS.jl")
include("math.jl")
include("strings.jl")
include("functors.jl")
include("PM.jl")
#include("template_matching.jl")

function isinside(v, poly)
    # See: http://www.sciencedirect.com/science/article/pii/S0925772101000128
    # "The point in polygon problem for arbitrary polygons"
    # An implementation of Hormann-Agathos (2001) Point in Polygon algorithm
    c = false
    r = v
    detq(q1,q2) = (q1[1]-r[1])*(q2[2]-r[2])-(q2[1]-r[1])*(q1[2]-r[2])
    N = length(poly)
    for i=1:N
        q1 = poly[i]
        q2 = poly[(i%N) + 1]
        (v == q1 || v == q2) && return false
        if (q1[2] < r[2]) != (q2[2] < r[2]) # crossing
            if q1[1] >= r[1]
                if q2[1] > r[1]
                    c = !c
                elseif ((detq(q1,q2) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            elseif q2[1] > r[1]
                if ((detq(q1,q2) > 0) == (q2[2] > q1[2])) # right crossing
                    c = !c
                end
            end
        end
    end
    return c
end
export isinside


function mean_Rotation(a,b,t)
    qa = Quat(a)
    qb = Quat(b)
    qa = [qa.w qa.x qa.y qa.z]
    qb = [qb.w qb.x qb.y qb.z]

    dot = qb*qa'
    DOT_THRESHOLD = 0.995
    if (dot[1] < 0.0)
        qb = -qb;
        dot = -dot;
    end
    abs_dot = abs.(dot)

    if (abs_dot[1] > DOT_THRESHOLD)
        result = qa.+ t.*(qb.-qa);
        result = normalize([result]);
        #return result;
        return RotXYZ(Quat(result[1]...))
    end

    theta_0 = acos(dot[1]);
    theta = theta_0*t;

    qab = qb.-qa.*dot
    qab = normalize([qab])
    d = qa.*cos(theta)
    e = qab.*sin.(theta)
    slerp = d + e[1]
    return RotXYZ(Quat(slerp...))
end
export mean_Rotation

function mean_Rotation_aux(R,len_R)
    if len_R>1
        log_len_R = Int(floor(log2(len_R)))
        R = R[1:2^log_len_R]
        len_R = length(R)
        for i=1:log_len_R
            Quat_list = []
            for j=1:2:len_R
                mean_tmp = mean_Rotation(R[j],R[j+1],0.5)
                push!(Quat_list,mean_tmp[1:3,1:3])
            end
            R = Quat_list
            len_R = length(R)
        end
    end
    return R[1]
end
export mean_Rotation_aux
end
