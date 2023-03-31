using BFM
using JLD2
using ProgressMeter

const Δx = 1.0
const N = 1000

function main()
    er = reshape(load("data.jld2", "er"), 43, 10, 10, :)
    bathy = reshape(load("data.jld2", "mbathy"), 10, 10)
    state = reshape(load("data.jld2", "d3state"), 43, 10, 10, :)

    BFM.initialize(10, 10, 43)
    BFM.setbathimetry(bathy)
    BFM.setenvironmentalfactors(er)

    source = similar(state)
    @showprogress for _ = 1:N
        BFM.run!(source, state)
        state += Δx * source
    end

    println("Done!")
end

main()
