
telip(x::Tuple) = x
telip(x) = (x,)
is_callable(x) = length(methods(x)) >= 1
export is_callable
∘(g,f) = begin
    @assert is_callable(g) && is_callable(f) "Composing non-callable objects"
    (args...) -> g(telip(f(args...))...)
end
export ∘

func(g) = assert(is_callable(x)) && (return x->g(x))

fprint_fps(g,n) = begin
    const fps_t = FPS(print_time = n,name = "IDSLoop")
    (args...) -> begin
        tic(fps_t)
        g(args...)
    end
end
export fprint_fps

fprint_runtime(g,n) = begin
    acum = 0.0
    counter = 0
    last_print_time = time()
    (args...) -> begin
        t = time()
        ret = g(args...)
        acum += time() - t;
        counter += 1
        if (t - last_print_time > n)
            avg = round(1e5*acum/counter)/100
            print("Average runtime of $(counter) runs : $avg ms\n")
            last_print_time = time()
            acum = 0.0
            counter = 0
        end
        ret
    end
end
export fprint_runtime

flimit_cycles(g,n,stop_func::Function) = begin
    const counter = Ref(1)
    (args...) -> begin
        if counter.x > n
            stop_func()
        end
        counter.x+=1
        g(args...)
    end
end
export flimit_cycles

flimit_fps(g,n) = begin
    const interval = 1/n
    last_time = Ref(time())
    first_run = Ref(true)
    last_g = []
    (args...) -> begin
        ctime = time() - last_time.x
        if !first_run.x && ctime < interval
            last_g
        else
            first_run.x  = false
            last_time.x = time()
            last_g = g(args...)
        end
        last_g
    end
end
export flimit_fps
