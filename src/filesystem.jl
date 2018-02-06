# module CommonTools
function filesdirs(path)
    cd = readdir(path)
    filter!(x->x[1] != '.',cd)
    dirs = isdir.(cd);
    return cd[!dirs] , cd[dirs]
end
export filesdirs

function includeallafiles(expr)
    myfullname = expr;
    localname = basename(myfullname);
    path = dirname(myfullname);
    (files,dirs) = filesdirs(path);
    for f in files
        if f == localname;
            continue;
        end;
        include(joinpath(path,f))
    end
end
export includeallafiles

ishidden(fname::String) = match(r"\\\.",fname) != nothing || match(r"^\.",fname) != nothing
ishidden(fnames::Vector{String}) = map(x->ishidden(x),fnames)
export ishidden

function listdirs_rec(path::String)
    V = Vector{String}();
    for (root, dirs, files) in walkdir(path)
        for dir in dirs
            if ishidden(root) || ishidden(dir) continue; end
            push!(V,joinpath(root, dir)) # path to directories
        end
    end
    V
end
export listdirs_rec

"return (path,file,ext)"
function fileparts(fullname)
    path = dirname(fullname)
    file = basename(fullname)
    m = match(r"([^\.]+)(\.(.+))?",file);
    f(x) = x == nothing ? "" : x;
    file = f(m.captures[1])
    ext = f(m.captures[3])
    return (path,file,ext)
end
export fileparts

saveitem(fname,item) = open(fname,"w") do f
    serialize(f,item)
end
export saveitem

loaditem(fname) = open(fname,"r") do f
    deserialize(f)
end
export loaditem

u8(x) = convert(Matrix{UInt8},round.(x))
export u8

using FileIO
cache = Dict{String,Any}()
function cached_load(fname)
    global cache
    if fname in keys(cache)
        return cache[fname]
    else
        return cache[fname] = load(fname)
    end
end
export cached_load


""" forward abspath """
function fabspath(path...)
    return replace(abspath(path...),"\\", "/")
end
export fabspath
