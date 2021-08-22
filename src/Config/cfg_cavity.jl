"""
    2d0f0v: ib_cavity(gam, Um, Vm, Tm) where {T<:AbstractArray{<:AbstractFloat,2}}
    2d1f2v: ib_cavity(gam, Um, Vm, Tm, u::T, v::T) where {T<:AbstractArray{<:AbstractFloat,2}}
    2d2f2v: ib_cavity(gam, Um, Vm, Tm, u::T, v::T, K) where {T<:AbstractArray{<:AbstractFloat,2}}

Initialize lid-driven cavity
"""
function ib_cavity(
    set::AbstractSetup,
    ps::AbstractPhysicalSpace,
    vs::Union{AbstractVelocitySpace,Nothing},
    gas::AbstractProperty,
    Um = 0.15,
    Vm = 0.0,
    Tm = 1.0,
)

    if set.nSpecies == 1

        prim = [1.0, 0.0, 0.0, 1.0]
        w = prim_conserve(prim, gas.γ)
        h = maxwellian(vs.u, prim)
        b = h .* gas.K / 2.0 / prim[end]

        primU = [1.0, Um, Vm, Tm]
        primD = deepcopy(prim)
        primL = deepcopy(prim)
        primR = deepcopy(prim)

        fw = function(args...)
            return w
        end

        bc = function(x, y)
            if y == ps.y1
                return primU
            else
                return prim
            end
        end

        if set.space[1:4] == "2d0f"
            return fw, bc
        elseif set.space == "2d1f2v"
            ff = function(args...)
                return h
            end

            return fw, ff, bc
        elseif set.space == "2d2f2v"
            ff = function(args...)
                return h, b
            end

            return fw, ff, bc
        end

    end

    return nothing

end
