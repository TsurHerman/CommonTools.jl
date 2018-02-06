mutable struct FPS
    quiet::Bool
    damper::Float64
    print_time::Float64
    name::String
    lasttime::Float64
    lastprinttime::Float64
    fps::Float64
    FPS(;quiet=false, damper=5, print_time  = 0.5 , name = "unnamed") =
        new(quiet,damper,print_time,name,time()-0.1,time()-0.1,0);
end
import Base.tic
function tic(t::FPS)
    printed = false
    curtime = time()
    elapsed = max(curtime - t.lasttime,1e-6)
    t.lasttime = curtime
    elapsedprint = curtime - t.lastprinttime
    curfps = (1.0/elapsed);
    factor = exp(-(abs(curfps-t.fps)/t.damper)^2)
    t.fps = t.fps*factor + curfps*(1-factor)
    if !t.quiet && elapsedprint>=t.print_time
        t.lastprinttime = curtime
        print("[$(t.name)]$(t.fps) fps\n");
        printed = true
    end
    return (t.fps,printed)
end
export FPS

(fps_t::FPS)() = tic(fps_t)

function match_images(vargin...)
    n = length(vargin)
    m = Integer(ceil(n/2))
    n = Integer(ceil(n/m))

    ax_base = PyPlot.subplot(m,n,1)
    ax_base[:imshow](vargin[1])
    for i=2:length(vargin)
        ax2 = PyPlot.subplot(m,n,i, sharex=ax_base,sharey=ax_base)
        ax2[:imshow](vargin[i])
    end
end
export match_images
