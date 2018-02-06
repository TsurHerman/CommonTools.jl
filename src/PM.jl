using Reactive
using StaticArrays,Rotations
const PM = StaticArrays.SArray{Tuple{4,4},Float32,2,16}
(::Type{PM})(R, T) = begin
    s_R = convert(SArray{Tuple{3,3},Float32,2,9},R)
    s_T = convert(SVector{3,Float32},T)
    PM(s_R,s_T)
end
(::Type{PM})(R::SArray{Tuple{3,3},Float32,2,9}, T::SVector{3,Float32}) = begin
    T0 = zero(Float32)
    T1 = one(Float32)
    @SMatrix [R[1,1] R[1,2] R[1,3] T[1];
              R[2,1] R[2,2] R[2,3] T[2];
              R[3,1] R[3,2] R[3,3] T[3];
              T0     T0     T0      T1];
end
export PM

const SPM = Signal{PM}
export SPM

using GeometryTypes
import Base.*
*(M::PM,p::Union{Point3,Vec3,SVector{3,Float32}}) = begin
    p = M * Vec4(p[1],p[2],p[3],1)
    Point3(p[1]/p[4],p[2]/p[4],p[3]/p[4])
end

import Base.convert
convert(::Type{SPM},x::Matrix) = Signal(PM(x))
convert(::Type{Signal{T}},x::T) where T = Signal(x)

#TODO deprecate this in vafor of vec
decompose_PM(trans::PM) = begin
    R = SMatrix{3,3}(trans[1:3,1:3])
    R = RotXYZ(R)
    angles = SVector{3}(R.theta1,R.theta2,R.theta3)
    T = SVector{3}(trans[1:3,4])
    (angles,T)
end

#TODO ue vec instead pf decompose
function lerp_PM(start_trans::PM,end_trans::PM,alpha)
    (o_angles,o_T) = decompose_PM(start_trans)
    (n_angles,n_T) = decompose_PM(end_trans)
    angles = alpha * n_angles + (1-alpha) * o_angles
    T = alpha * n_T + (1-alpha) * o_T
    return PM(Array(RotXYZ(angles...)),T)
end
export lerp_PM

import Base.vec
vec(trans::PM) = begin
    R = RotXYZ(trans[1:3,1:3])
    angles = SVector{3}(R.theta1,R.theta2,R.theta3)
    T = trans[1:3,4]
    [angles...,T...]
end

(::Type{PM})(V::AbstractVector) = begin
    if length(V) != 6
        error("6 elements required to construct PM(Projection Matrix) from vector")
    end
    PM(RotXYZ(V[1],V[2],V[3]),V[4:6])
end
