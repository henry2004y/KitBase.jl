# ============================================================
# Reconstruction and Slope Limiters
# ============================================================

export linear, vanleer, minmod, superbee, vanalbaba, weno5
export reconstruct2, reconstruct2!, reconstruct3, reconstruct3!, reconstruct4!
export modal_filter!

include("recon_limiter.jl")
include("recon_filter.jl")

# ------------------------------------------------------------
# Reconstruction methodologies
# ------------------------------------------------------------

"""
    reconstruct2(wL, wR, Δx)
    reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,1}}
    reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,2}}
    reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,3}}

Two-cell reconstruction

"""
reconstruct2(wL, wR, Δx) = (wR - wL) / Δx

reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,1}} = (wR .- wL) ./ Δx

function reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,2}}

    s = zeros(axes(wL))
    for j in axes(s, 2)
        s[:, j] .= reconstruct2(wL[:, j], wR[:, j], Δx)
    end

    return s

end

function reconstruct2(wL::T, wR::T, Δx) where {T<:AbstractArray{<:Real,3}}

    s = zeros(axes(wL))
    for k in axes(s, 3), j in axes(s, 2)
        s[:, j, k] .= reconstruct2(wL[:, j, k], wR[:, j, k], Δx)
    end

    return s

end


"""
    reconstruct2!(
        sw::X,
        wL::Y,
        wR::Y,
        Δx,
    ) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}

    reconstruct2!(
        sw::X,
        wL::Y,
        wR::Y,
        Δx,
    ) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

    reconstruct2!(
        sw::X,
        wL::Y,
        wR::Y,
        Δx,
    ) where {X<:AbstractArray{<:AbstractFloat,3},Y<:AbstractArray{<:Real,3}}

Two-cell reconstruction

"""
function reconstruct2!(
    sw::X,
    wL::Y,
    wR::Y,
    Δx,
) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}
    sw .= (wR .- wL) ./ Δx
end

function reconstruct2!(
    sw::X,
    wL::Y,
    wR::Y,
    Δx,
) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

    for j in axes(sw, 2)
        swj = @view sw[:, j]
        reconstruct2!(swj, wL[:, j], wR[:, j], Δx)
    end

end

function reconstruct2!(
    sw::X,
    wL::Y,
    wR::Y,
    Δx,
) where {X<:AbstractArray{<:AbstractFloat,3},Y<:AbstractArray{<:Real,3}}

    for k in axes(sw, 3), j in axes(sw, 2)
        swjk = @view sw[:, j, k]
        reconstruct2!(swjk, wL[:, j, k], wR[:, j, k], Δx)
    end

end


"""
    reconstruct3(
        wL::T,
        wN::T,
        wR::T,
        ΔxL::T,
        ΔxR::T,
        limiter = :vanleer::Symbol,
    ) where {T}

    reconstruct3(
        wL::T,
        wN::T,
        wR::T,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {T<:AbstractArray{<:Real,1}}

    reconstruct3(
        wL::T,
        wN::T,
        wR::T,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {T<:AbstractArray{<:Real,2}}

    function reconstruct3(
        wL::T,
        wN::T,
        wR::T,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {T<:AbstractArray{<:Real,3}}

Three-cell reconstruction

"""
function reconstruct3(
    wL::T,
    wN::T,
    wR::T,
    ΔxL::T,
    ΔxR::T,
    limiter = :vanleer::Symbol,
) where {T}
    sL = (wN - wL) / ΔxL
    sR = (wR - wN) / ΔxR

    return eval(limiter)(sL, sR)
end

function reconstruct3(
    wL::T,
    wN::T,
    wR::T,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {T<:AbstractArray{<:Real,1}}
    sL = (wN .- wL) ./ ΔxL
    sR = (wR .- wN) ./ ΔxR

    return eval(limiter).(sL, sR)
end

function reconstruct3(
    wL::T,
    wN::T,
    wR::T,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {T<:AbstractArray{<:Real,2}}

    s = zeros(axes(wL))
    for j in axes(s, 2)
        s[:, j] .= reconstruct3(wL[:, j], wN[:, j], wR[:, j], ΔxL, ΔxR, limiter)
    end

    return s

end

function reconstruct3(
    wL::T,
    wN::T,
    wR::T,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {T<:AbstractArray{<:Real,3}}

    s = zeros(axes(wL))
    for k in axes(s, 3), j in axes(s, 2)
        s[:, j, k] .= reconstruct3(wL[:, j, k], wN[:, j, k], wR[:, j, k], ΔxL, ΔxR, limiter)
    end

    return s

end


"""
    reconstruct3!(
        sw::X,
        wL::Y,
        wN::Y,
        wR::Y,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}

    reconstruct3!(
        sw::X,
        wL::Y,
        wN::Y,
        wR::Y,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

    reconstruct3!(
        sw::X,
        wL::Y,
        wN::Y,
        wR::Y,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,3},Y<:AbstractArray{<:Real,3}}

    reconstruct3!(
        sw::X,
        wL::Y,
        wN::Y,
        wR::Y,
        ΔxL,
        ΔxR,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,4},Y<:AbstractArray{<:Real,4}}

Three-cell reconstruction

"""
function reconstruct3!(
    sw::X,
    wL::Y,
    wN::Y,
    wR::Y,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}
    sL = (wN .- wL) ./ ΔxL
    sR = (wR .- wN) ./ ΔxR

    sw .= eval(limiter).(sL, sR)
end

function reconstruct3!(
    sw::X,
    wL::Y,
    wN::Y,
    wR::Y,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

    for j in axes(sw, 2)
        swj = @view sw[:, j]
        reconstruct3!(swj, wL[:, j], wN[:, j], wR[:, j], ΔxL, ΔxR, limiter)
    end

end

function reconstruct3!(
    sw::X,
    wL::Y,
    wN::Y,
    wR::Y,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,3},Y<:AbstractArray{<:Real,3}}

    for k in axes(sw, 3), j in axes(sw, 2)
        swjk = @view sw[:, j, k]
        reconstruct3!(swjk, wL[:, j, k], wN[:, j, k], wR[:, j, k], ΔxL, ΔxR, limiter)
    end

end

function reconstruct3!(
    sw::X,
    wL::Y,
    wN::Y,
    wR::Y,
    ΔxL,
    ΔxR,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,4},Y<:AbstractArray{<:Real,4}}

    for l in axes(sw, 4), k in axes(sw, 3), j in axes(sw, 2)
        sjkl = @view sw[:, j, k, l]
        reconstruct3!(
            sjkl,
            wL[:, j, k, l],
            wN[:, j, k, l],
            wR[:, j, k, l],
            ΔxL,
            ΔxR,
            limiter,
        )
    end

end


"""
    function reconstruct4!(
        sw::X,
        wN::Y
        w1::Y,
        w2::Y,
        w3::Y,
        Δx1,
        Δx2,
        Δx3,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}

    function reconstruct4!(
        sw::X,
        wN::Y
        w1::Y,
        w2::Y,
        w3::Y,
        Δx1,
        Δx2,
        Δx3,
        limiter = :vanleer::Symbol,
    ) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

Four-cell reconstruction for triangular mesh

"""
function reconstruct4!(
    sw::X,
    wN::Y,
    w1::Y,
    w2::Y,
    w3::Y,
    Δx1,
    Δx2,
    Δx3,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,1},Y<:AbstractArray{<:Real,1}}
    s1 = (wN .- w1) ./ Δx1
    s2 = (wN .- w2) ./ Δx2
    s3 = (wN .- w3) ./ Δx3

    sw .= eval(limiter).(s1, s2, s3)
end

function reconstruct4!(
    sw::X,
    wN::Y,
    w1::Y,
    w2::Y,
    w3::Y,
    Δx1,
    Δx2,
    Δx3,
    limiter = :vanleer::Symbol,
) where {X<:AbstractArray{<:AbstractFloat,2},Y<:AbstractArray{<:Real,2}}

    for j in axes(sw, 2)
        swj = @view sw[:, j]
        reconstruct4!(swj, wN[:, j], w1[:, j], w2[:, j], w3[:, j], Δx1, Δx2, Δx3, limiter)
    end

end
