import CommonTools
using CommonTools: parseini,cached_load
using Base.Test
using PyPlot
imshow(rand(100,100))
# write your own tests here
# @test 1 == 1
println("Workout")
using StaticArrays
using GLVisualize
using Rotations,Parameters
window = GLVisualize.glscreen()

using BenchmarkTools
#
testsets = ["spawn","repl","dict"]
for t in testsets
    A = joinpath(JULIA_HOME,
    Base.DATAROOTDIR, "julia", "test", "runtests.jl");
    global ARGS = [t];
    include(A)
    nothing
end
using FileIO
using MeshIO
using StaticArrays
using GeometryTypes
ply_1 = string(@__DIR__ ,"/sawbone.ply")
ply = load(ply_1)
ply

ini_1 = string(@__DIR__ ,"/HMD.ini")
CommonTools.parseini(ini_1)

_view(visualize(ply),window)
@async GLWindow.waiting_renderloop(window)
sleep(10)
addprocs(1)
@spawn rand(100,100)
GLWindow.destroy!(window)
ply = nothing

rmprocs(2)
println(nworkers())
