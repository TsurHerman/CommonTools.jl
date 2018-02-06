
const IniType = Dict{String,Dict{String,Any}}
export IniType

function parseini(fname::String)::IniType
    initxt = IniType();
    fid = open(fname)
    blockname = "default"
    seekstart(fid)
    lines = eachline(fid)
    lastkey = ""
    for line in lines
        # skip comments and newlines
        m = match(r"([^#]*)",line);
        line  = strip(chomp(m.captures[1]));
        if isempty(line)
            continue
        end
        # parse blockname
        m = match(r"^\s*\[\s*([^\]]+)\s*\]$", line)
        if (m != nothing)
            blockname = m.captures[1]
            continue
        end
        # parse key/value
        m = match(r"^\s*([^=]*\w)\s*=\s*(.*)\s*$", line)
        if (m != nothing) #Found a key
            lastkey = m.captures[1]
            if haskey(initxt,blockname)
                initxt[blockname][lastkey] = m.captures[2];
            else
                initxt[blockname] = Dict(lastkey => m.captures[2]);
            end
        else #Not a key and not a comment append to last known block and key
            initxt[blockname][lastkey] = string(initxt[blockname][lastkey],line)
        end
    end
    close(fid);
    #eval loop
    mblock=[];mkey=[]
    try
        foreach(keys(initxt)) do block
            mblock = block
            foreach(keys(initxt[block])) do key
                mkey = key
                initxt[block][key] = eval(parse(initxt[block][key]))
            end
        end
    catch e
        error("Error encountered parsing [$(mblock)][$mkey] with\n val: \n $(initxt[mblock][mkey])")
    end
    initxt
end
export parseini

writeln(fid,line) = begin
    isempty(line) && (line = "\n")
    line[end] != '\n' && (line = string(line,"\n"))
    write(fid,line)
end

function saveini{T<:Any}(fname::String,D::Dict{String,Dict{String,T}})
    fid = open(fname,"w+") do fid
        foreach(keys(D)) do block
            block = strip(block)
            writeln(fid,"\n[$block]")
            foreach(keys(D[block])) do key
                key = strip(key)
                writeln(fid,"$key =  $(print_var(D[block][key]))")
            end
        end
    end
    nothing
end
export saveini

function setvarini(fname::String,section::String,varname::String,var)
    section = strip(section)
    varname= strip(varname)
    lines = try
        open(fid->collect(eachline(fid)),fname)
    catch
        info("File not found: creating new file $fname")
        open(fname,"w") do fid
            writeln(fid,"\n[$section]")
            writeln(fid,"$varname = $(print_var(var))")
        end
        return
    end
    S = parseini_structure(lines)
    if !(section in keys(S))
        info("Section [$section] not found in $fname creating new ")
        open(fname,"w") do fid
            writeln(fid,"\n[$section]")
            writeln(fid,"$varname = $(print_var(var))")
            foreach(line->writeln(fid,line),lines)
        end
        return
    end
    if varname in keys(S[section].children)
        info("Variable found: replacing $varname = ")
        insert_line = S[section][varname].start_line-1
        restart_line = S[section][varname].end_line+1
    else
        info("Variable not found: creating $varname = ")
        insert_line = S[section].start_line
        restart_line = S[section].start_line+1
    end
    open(fname,"w") do fid
        for i=1:insert_line writeln(fid,lines[i]); end
        writeln(fid,"$varname = $(print_var(var))")
        for i=restart_line:length(lines) writeln(fid,lines[i]); end
    end
end
export setvarini


print_var(S::String) = string("\"",replace(S,"\\","\\\\"),"\"")
print_var(S::Any) = begin
    res = sprint(print,S)
    for typ in (:Any,:Int32,:Int64,:Float64,:Float32)
        res = replace(res,"$(typ)[","[")
        res = replace(res,",$(typ)[",",[")
    end
    res = replace(res,"],[","],\n\t\t[")
    res
end

print_var{T <: Real}(M::Matrix{T}) = begin
    M = Matrix{Float64}(M)
    res = sprint(print,M)
    res = replace(res,";",";\n\t\t")
end

using StaticArrays
print_var{N1,N2,T <: Real}(M::SMatrix{N1,N2,T}) = begin
    M = Matrix{Float64}(M)
    res = sprint(print,M)
    res = replace(res,";",";\n\t\t")
end

print_var{T <: Real}(VV::Vector{Vector{T}}) = begin
    res = sprint(print,VV)
    res = replace(res,"Array{$T,1}","")
    res = replace(res,"],[","],\n\t\t[")
    res = replace(res,"[[","[\n\t\t[")
end

mutable struct iniNodeInfo
    typ::Symbol
    start_line::Integer
    end_line::Integer
    children
    iniNodeInfo(typ,sl,el) = new(typ,sl,el,Dict{String,iniNodeInfo}())
end
import Base: getindex,setindex!
getindex(ini::iniNodeInfo,a) = ini.children[a]
setindex!(ini::iniNodeInfo,val,key) = setindex!(ini.children,val,key)

function parseini_structure(fname::String)
    open(fname) do fid
        parseini_structure(collect(eachline(fid)))
    end
end
function parseini_structure(lines::Vector{String})
    S = Dict{String,iniNodeInfo}();
    blockname = "default"
    S[blockname] = iniNodeInfo(:block,1,0)
    lastkey = ""
    for idx=1:length(lines)
        line = lines[idx]
        # skip comments and newlines
        m = match(r"([^#]*)",line);
        line  = strip(chomp(m.captures[1]));
        if isempty(line)
            continue
        end
        # parse blockname
        m = match(r"^\s*\[\s*([^\]]+)\s*\]$", line)
        if (m != nothing)
            blockname = m.captures[1]
            S[blockname] = iniNodeInfo(:block,idx,idx)
            continue
        end
        S[blockname].end_line += 1
        # parse key/value
        m = match(r"^\s*([^=]*\w)\s*=\s*(.*)\s*$", line)
        if (m != nothing) #Found a key
            lastkey = m.captures[1]
            S[blockname][lastkey] = iniNodeInfo(:key,idx,idx)
        else #Not a key and not a comment append to last known block and key
            S[blockname][lastkey].end_line += 1
        end
    end
    S
end
nothing
