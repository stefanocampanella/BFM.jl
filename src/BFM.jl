module BFM

using Libdl

macro dlsym(func, lib)
    z = Ref{Ptr{Cvoid}}(C_NULL)
    quote
        let zlocal = $z[]
            if zlocal == C_NULL
                zlocal = dlsym($(esc(lib))::Ptr{Cvoid}, $(esc(func)))::Ptr{Cvoid}
                $z[] = zlocal
            end
            zlocal
        end
    end
end

libbfm_handle = C_NULL
const bfm_dims = Int32[]

const NO_ER = 11
const NO_STATES = 51

function __init__()
    if !haskey(ENV, "JULIA_BFM_PATH")
        error("The environment variable `JULIA_BFM_PATH` should be set.")
    end
    prefix =  ENV["JULIA_BFM_PATH"]
    libbfm = "$prefix/lib/libbfm"

    global libbfm_handle = dlopen(libbfm)
end


function initialize(nx, ny, nz)
    append!(bfm_dims, [nx, ny, nz])
    nx_ref, ny_ref, nz_ref = map(Ref{Int32}, bfm_dims)
    ccall(@dlsym("initialize", libbfm_handle), Nothing, (Ref{Int32}, Ref{Int32}, Ref{Int32}), nx_ref, ny_ref, nz_ref)
end

function setenvironmentalfactors(ers)
    ccall(@dlsym("inputecologydynamics", libbfm_handle), Nothing, (Ref{Float64},), ers)
end

function setbathimetry(bathy)
    ccall(@dlsym("inputbathymetry", libbfm_handle), Nothing, (Ref{Int32},), bathy)
end

function setstate(state)
    ccall(@dlsym("setd3state", libbfm_handle), Nothing, (Ref{Float64},), state)
end

function getsource!(source)
    ccall(@dlsym("getd3source", libbfm_handle), Nothing, (Ref{Float64},), source)
end

function computefluxes()
    ccall(@dlsym("run", libbfm_handle), Nothing, ())
end

function setup(er, bathy)
    if isempty(bfm_dims)
        error("Initialize the system first!")
    elseif dims(er) != (bfm_dims..., NO_ER)
        throw(DimensionMismatch("ER with wrong dimensions"))
    elseif dims(bathy) != (bfm_dims[1], bfm_dims[2])
        throw(DimensionMismatch("Bathy with wrong dimensions"))
    elseif maximum(bathy) > bfm_dims[3]
        throw(DomainError("Bathy too deep"))
    end
    setenvironmentalfactors(er)
    setbathymetry(bathy)
end

function run!(source, state)
    setstate(state)
    computefluxes()
    getsource!(source) 
end

function run(state)
    source = similar(state)
    run!(source, state)
    source
end

end