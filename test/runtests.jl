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
import Optim

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
@async GLWindow.renderloop(window)
sleep(10)
addprocs(1)
@spawn rand(100,100)
GLWindow.destroy!(window)
ply = nothing

rmprocs(2)
println(nworkers())

import LsqFit

# a two-parameter exponential model
# x: array of independent variables
# p: array of model parameters
model(x, p) = p[1]*exp.(-x.*p[2])

# some example data
# xdata: independent variables
# ydata: dependent variable
xdata = linspace(0,10,20)
ydata = model(xdata, [1.0 2.0]) + 0.01*randn(length(xdata))
p0 = [0.5, 0.5]

fit = LsqFit.curve_fit(model, xdata, ydata, p0)
# fit is a composite type (LsqFitResult), with some interesting values:
#	fit.dof: degrees of freedom
#	fit.param: best fit parameters
#	fit.resid: residuals = vector of residuals
#	fit.jacobian: estimated Jacobian at solution

# We can estimate errors on the fit parameters,
# to get 95% confidence error bars:
errors = LsqFit.estimate_errors(fit, 0.95)

# The finite difference method is used above to approximate the Jacobian.
# Alternatively, a function which calculates it exactly can be supplied instead.
function jacobian_model(x,p)
    J = Array{Float64}(length(x),length(p))
    J[:,1] = exp.(-x.*p[2])    #dmodel/dp[1]
    J[:,2] = -x.*p[1].*J[:,1]  #dmodel/dp[2]
    J
end
fit = LsqFit.curve_fit(model, jacobian_model, xdata, ydata, p0)
println(fit)
