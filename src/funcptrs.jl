# Create mutable structs to cache function pointers
macro create_func_ptr_struct(name, syms)
    e = :(mutable struct $name end)
    for s in eval(syms)
        push!(e.args[3].args, :($s::Ptr{Nothing}))
    end
    push!(e.args[3].args, :( 
        $name() = new( fill(C_NULL,length($syms))... )
    ) )
    e
end

@create_func_ptr_struct LibGR_Ptrs include("libgr_syms.jl")
@create_func_ptr_struct LibGRM_Ptrs include("libgrm_syms.jl")
@create_func_ptr_struct LibGR3_Ptrs include("libgr3_syms.jl")

const libGR_handle  = Ref{Ptr{Nothing}}()
const libGR3_handle = Ref{Ptr{Nothing}}()
const libGRM_handle = Ref{Ptr{Nothing}}()

const libGR_ptrs  = LibGR_Ptrs()
const libGRM_ptrs = LibGRM_Ptrs()
const libGR3_ptrs = LibGR3_Ptrs()

const libs_loaded = Ref(false)

"""
    load_libs(always = false)
    Load shared GR libraries from either GR_jll or from GR tarball.
    always is a boolean flag that is passed through to init.
"""
function load_libs(always::Bool = false)
    libGR_handle[]  = Libdl.dlopen(GRPreferences.libGR[])
    libGR3_handle[] = Libdl.dlopen(GRPreferences.libGR3[])
    libGRM_handle[] = Libdl.dlopen(GRPreferences.libGRM[])
    lp = GRPreferences.libpath[]
    env, components, sep = if os === :Windows
        hard_limit = 4095 - length(lp) - 1
        prev = if (tmp = get(ENV, "PATH", "")) |> length > hard_limit
            tmp[1:hard_limit]
        else
            tmp
        end
        "PATH", (lp, prev), ";"
    elseif os === :Darwin
        "DYLD_FALLBACK_LIBRARY_PATH", nothing, ':'
    else
        "LD_LIBRARY_PATH", nothing, ":"
    end
    ENV[env] = join((lp, something(components, get(ENV, env, ""))), sep)
    @debug "Set library search path `$env` to" ENV[env]
    libs_loaded[] = true
    check_env[] = true
    init(always)
end

function get_func_ptr(handle::Ref{Ptr{Nothing}}, ptrs::Union{LibGR_Ptrs, LibGRM_Ptrs, LibGR3_Ptrs}, func::Symbol, loaded=libs_loaded[])
    loaded || load_libs(true)
    s = getfield(ptrs, func)
    if s == C_NULL
        s = Libdl.dlsym(handle[], func)
        setfield!(ptrs, func, s)
    end
    return getfield(ptrs,func)
end

libGR_ptr(func) = get_func_ptr(libGR_handle, libGR_ptrs, func)
libGRM_ptr(func) = get_func_ptr(libGRM_handle, libGRM_ptrs, func)
libGR3_ptr(func) = get_func_ptr(libGR3_handle, libGR3_ptrs, func)
