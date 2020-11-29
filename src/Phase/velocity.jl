# ============================================================
# Methods of Particle Velocity Space
# ============================================================

"""
1D velocity space

- @consts: u0, u1, nu, u, du, weights

"""
struct VSpace1D{T<:AbstractArray{Float64,1}} <: AbstractVelocitySpace

    u0::Float64
    u1::Float64
    nu::Int64
    u::T
    du::T
    weights::T

    VSpace1D() = VSpace1D(-5, 5, 50)
    VSpace1D(U0::Real, U1::Real) = VSpace1D(U0, U1, 50)

    function VSpace1D(
        U0::Real,
        U1::Real,
        UNUM::Int,
        TYPE = "rectangle"::String,
        NG = 0::Int,
    )

        u0 = Float64(U0)
        u1 = Float64(U1)
        nu = UNUM
        δ = (u1 - u0) / nu
        u = OffsetArray{Float64}(undef, 1-NG:nu+NG)
        du = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" # rectangular
            for i in eachindex(u)
                u[i] = u0 + (i - 0.5) * δ
                du[i] = δ
                weights[i] = δ
            end
        elseif TYPE == "newton" # newton-cotes
            for i in eachindex(u)
                u[i] = u0 + (i - 0.5) * δ
                du[i] = δ
                weights[i] = newton_cotes(i + NG, UNUM + NG * 2) * δ
            end
        elseif TYPE == "gauss" # gaussian
            throw("Gaussian integration coming soon")
        else
            throw("no velocity quadrature rule found")
        end

        new{typeof(u)}(u0, u1, nu, u, du, weights)

    end # constructor

end # struct


"""
2D velocity space

- @consts: u0, u1, nu, v0, v1, nv, u, v, du, dv, weights

"""
struct VSpace2D{T<:AbstractArray{Float64,2}} <: AbstractVelocitySpace

    u0::Float64
    u1::Float64
    nu::Int64
    v0::Float64
    v1::Float64
    nv::Int64
    u::T
    v::T
    du::T
    dv::T
    weights::T

    VSpace2D() = VSpace2D(-5, 5, 28, -5, 5, 28)
    VSpace2D(U0::Real, U1::Real, V0::Real, V1::Real) =
        VSpace2D(U0, U1, 28, V0, V1, 28)

    function VSpace2D(
        U0::Real,
        U1::Real,
        UNUM::Int,
        V0::Real,
        V1::Real,
        VNUM::Int,
        TYPE = "rectangle"::String,
        NGU = 0::Int,
        NGV = 0::Int,
    )

        u0 = Float64(U0)
        u1 = Float64(U1)
        nu = UNUM
        δu = (u1 - u0) / nu
        v0 = Float64(V0)
        v1 = Float64(V1)
        nv = VNUM
        δv = (v1 - v0) / nv
        u = OffsetArray{Float64}(undef, 1-NGU:nu+NGU, 1-NGV:nv+NGV)
        v = similar(u)
        du = similar(u)
        dv = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" #// rectangular formula
            for j in axes(u, 2)
                for i in axes(u, 1)
                    u[i, j] = u0 + (i - 0.5) * δu
                    v[i, j] = v0 + (j - 0.5) * δv
                    du[i, j] = δu
                    dv[i, j] = δv
                    weights[i, j] = δu * δv
                end
            end
        elseif TYPE == "newton" #// newton-cotes formula
            for j in axes(u, 2)
                for i in axes(u, 1)
                    u[i, j] = u0 + (i - 0.5) * δu
                    v[i, j] = v0 + (j - 0.5) * δv
                    du[i, j] = δu
                    dv[i, j] = δv
                    weights[i, j] =
                        newton_cotes(i + NGU, UNUM + NGU * 2) *
                        δu *
                        newton_cotes(j + NGV, VNUM + NGV * 2) *
                        δv
                end
            end
        elseif TYPE == "gauss" #// gaussian integration
            println("Gaussian integration coming soon")
        else
            println("error: no velocity quadrature rule")
        end

        new{typeof(u)}(u0, u1, nu, v0, v1, nv, u, v, du, dv, weights)

    end # constructor

end # struct


"""
3D velocity space

- @consts: u0, u1, nu, v0, v1, nv, w0, w1, nw, u, v, w, du, dv, dw, weights

"""
struct VSpace3D{T<:AbstractArray{Float64,3}} <: AbstractVelocitySpace

    u0::Float64
    u1::Float64
    nu::Int64
    v0::Float64
    v1::Float64
    nv::Int64
    w0::Float64
    w1::Float64
    nw::Int64
    u::T
    v::T
    w::T
    du::T
    dv::T
    dw::T
    weights::T

    VSpace3D() = VSpace3D(-5, 5, 28, -5, 5, 28, -5, 5, 28)
    VSpace3D(U0::Real, U1::Real, V0::Real, V1::Real, W0::Real, W1::Real) =
        VSpace2D(U0, U1, 28, V0, V1, 28, W0, W1, 28)

    function VSpace3D(
        U0::Real,
        U1::Real,
        UNUM::Int,
        V0::Real,
        V1::Real,
        VNUM::Int,
        W0::Real,
        W1::Real,
        WNUM::Int,
        TYPE = "rectangle"::String,
        NGU = 0::Int,
        NGV = 0::Int,
        NGW = 0::Int,
    )

        u0 = Float64(U0)
        u1 = Float64(U1)
        nu = UNUM
        δu = (u1 - u0) / nu
        v0 = Float64(V0)
        v1 = Float64(V1)
        nv = VNUM
        δv = (v1 - v0) / nv
        w0 = Float64(W0)
        w1 = Float64(W1)
        nw = WNUM
        δw = (w1 - w0) / nw
        u = OffsetArray{Float64}(
            undef,
            1-NGU:nu+NGU,
            1-NGV:nv+NGV,
            1-NGW:nw+NGW,
        )
        v = similar(u)
        w = similar(u)
        du = similar(u)
        dv = similar(u)
        dw = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" #// rectangular formula
            for k in axes(u, 3), j in axes(u, 2), i in axes(u, 1)
                u[i, j, k] = u0 + (i - 0.5) * δu
                v[i, j, k] = v0 + (j - 0.5) * δv
                w[i, j, k] = w0 + (k - 0.5) * δw
                du[i, j, k] = δu
                dv[i, j, k] = δv
                dw[i, j, k] = δw
                weights[i, j, k] = δu * δv * δw
            end
        elseif TYPE == "newton" #// newton-cotes formula
            for k in axes(u, 3), j in axes(u, 2), i in axes(u, 1)
                u[i, j, k] = u0 + (i - 0.5) * δu
                v[i, j, k] = v0 + (j - 0.5) * δv
                w[i, j, k] = w0 + (k - 0.5) * δw
                du[i, j, k] = δu
                dv[i, j, k] = δv
                dw[i, j, k] = δw
                weights[i, j, k] =
                    newton_cotes(i + NGU, UNUM + NGU * 2) *
                    δu *
                    newton_cotes(j + NGV, VNUM + NGV * 2) *
                    δv *
                    newton_cotes(k + NGW, WNUM + NGW * 2) *
                    δw
            end
        elseif TYPE == "gauss" #// gaussian integration
            println("Gaussian integration coming soon")
        else
            println("error: no velocity quadrature rule")
        end

        new{typeof(u)}(
            u0,
            u1,
            nu,
            v0,
            v1,
            nv,
            w0,
            w1,
            nw,
            u,
            v,
            w,
            du,
            dv,
            dw,
            weights,
        )

    end # constructor

end # struct


"""
1D multi-component velocity space

- @consts: u0, u1, nu, u, du, weights

"""
struct MVSpace1D{T<:AbstractArray{Float64,2}} <: AbstractVelocitySpace

    u0::Array{Float64,1}
    u1::Array{Float64,1}
    nu::Int64
    u::T
    du::T
    weights::T

    MVSpace1D() = MVSpace1D(-5, 5, -10, 10, 28)
    MVSpace1D(U0::Real, U1::Real, V0::Real, V1::Real) =
        MVSpace1D(U0, U1, V0, V1, 28)

    function MVSpace1D(
        Ui0::Real,
        Ui1::Real,
        Ue0::Real,
        Ue1::Real,
        UNUM::Int,
        TYPE = "rectangle"::String,
        NG = 0::Int,
    )

        u0 = [Ui0, Ue0]
        u1 = [Ui1, Ue1]
        nu = UNUM
        δ = (u1 .- u0) ./ nu
        u = OffsetArray{Float64}(undef, 1-NG:nu+NG, 1:2)
        du = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" #// rectangular formula
            for j in axes(u, 2), i in axes(u, 1)
                u[i, j] = u0[j] + (i - 0.5) * δ[j]
                du[i, j] = δ[j]
                weights[i, j] = δ[j]
            end
        elseif TYPE == "newton" #// newton-cotes formula
            for j in axes(u, 2), i in axes(u, 1)
                u[i, j] = u0[j] + (i - 0.5) * δ[j]
                du[i, j] = δ[j]
                weights[i, j] = newton_cotes(i + NG, UNUM + NG * 2) * δ[j]
            end
        elseif TYPE == "gauss" #// gaussian integration
            println("Gaussian integration coming soon")
        else
            println("error: no velocity quadrature rule")
        end

        new{typeof(u)}(u0, u1, nu, u, du, weights)

    end # constructor

end # struct


"""
2D multi-component velocity space

- @consts: u0, u1, nu, v0, v1, nv, u, v, du, dv, weights

"""
struct MVSpace2D{T<:AbstractArray{Float64,3}} <: AbstractVelocitySpace

    u0::Array{Float64,1}
    u1::Array{Float64,1}
    nu::Int64
    v0::Array{Float64,1}
    v1::Array{Float64,1}
    nv::Int64
    u::T
    v::T
    du::T
    dv::T
    weights::T

    MVSpace2D() = MVSpace2D(-5, 5, -10, 10, 28, -5, 5, -10, 10, 28)
    MVSpace2D(U0::Real, U1::Real, V0::Real, V1::Real) =
        MVSpace2D(U0, U1, U0, U1, 28, V0, V1, V0, V1, 28)

    function MVSpace2D(
        Ui0::Real,
        Ui1::Real,
        Ue0::Real,
        Ue1::Real,
        UNUM::Int,
        Vi0::Real,
        Vi1::Real,
        Ve0::Real,
        Ve1::Real,
        VNUM::Int,
        TYPE = "rectangle"::String,
        NGU = 0::Int,
        NGV = 0::Int,
    )

        u0 = Float64.([Ui0, Ue0])
        u1 = Float64.([Ui1, Ue1])
        nu = UNUM
        δu = (u1 .- u0) ./ nu
        v0 = Float64.([Vi0, Ve0])
        v1 = Float64.([Vi1, Ve1])
        nv = VNUM
        δv = (v1 .- v0) ./ nv
        u = OffsetArray{Float64}(undef, 1-NGU:nu+NGU, 1-NGV:nv+NGV, 1:2)
        v = similar(u)
        du = similar(u)
        dv = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" #// rectangular formula
            for k in axes(u, 3), j in axes(u, 2), i in axes(u, 1)
                u[i, j, k] = u0[k] + (i - 0.5) * δu[k]
                v[i, j, k] = v0[k] + (j - 0.5) * δv[k]
                du[i, j, k] = δu[k]
                dv[i, j, k] = δv[k]
                weights[i, j, k] = δu[k] * δv[k]
            end
        elseif TYPE == "newton" #// newton-cotes formula
            for k in axes(u, 3), j in axes(u, 2), i in axes(u, 1)
                u[i, j, k] = u0[k] + (i - 0.5) * δu[k]
                v[i, j, k] = v0[k] + (j - 0.5) * δv[k]
                du[i, j, k] = δu[k]
                dv[i, j, k] = δv[k]
                weights[i, j, k] =
                    newton_cotes(i + NGU, UNUM + NGU * 2) *
                    δu[k] *
                    newton_cotes(j + NGV, VNUM + NGV * 2) *
                    δv[k]
            end
        elseif TYPE == "gauss" #// gaussian integration
            println("Gaussian integration coming soon")
        else
            println("error: no velocity quadrature rule")
        end

        new{typeof(u)}(u0, u1, nu, v0, v1, nv, u, v, du, dv, weights)

    end # constructor

end # struct


"""
3D multi-component velocity space

- @consts: u0, u1, nu, v0, v1, nv, w0, w1, nw, u, v, w, du, dv, dw, weights

"""
struct MVSpace3D{T<:AbstractArray{Float64,4}} <: AbstractVelocitySpace

    u0::Array{Float64,1}
    u1::Array{Float64,1}
    nu::Int64
    v0::Array{Float64,1}
    v1::Array{Float64,1}
    nv::Int64
    w0::Array{Float64,1}
    w1::Array{Float64,1}
    nw::Int64
    u::T
    v::T
    w::T
    du::T
    dv::T
    dw::T
    weights::T

    MVSpace3D() =
        MVSpace3D(-5, 5, -10, 10, 20, -5, 5, -10, 10, 20, -5, 5, -10, 10, 20)
    MVSpace3D(U0::Real, U1::Real, V0::Real, V1::Real, W0::Real, W1::Real) =
        MVSpace3D(U0, U1, U0, U1, 20, V0, V1, V0, V1, 20, W0, W1, W0, W1, 20)

    function MVSpace3D(
        Ui0::Real,
        Ui1::Real,
        Ue0::Real,
        Ue1::Real,
        UNUM::Int,
        Vi0::Real,
        Vi1::Real,
        Ve0::Real,
        Ve1::Real,
        VNUM::Int,
        Wi0::Real,
        Wi1::Real,
        We0::Real,
        We1::Real,
        WNUM::Int,
        TYPE = "rectangle"::String,
        NGU = 0::Int,
        NGV = 0::Int,
        NGW = 0::Int,
    )

        u0 = Float64.([Ui0, Ue0])
        u1 = Float64.([Ui1, Ue1])
        nu = UNUM
        δu = (u1 .- u0) ./ nu
        v0 = Float64.([Vi0, Ve0])
        v1 = Float64.([Vi1, Ve1])
        nv = VNUM
        δv = (v1 .- v0) ./ nv
        w0 = Float64.([Wi0, We0])
        w1 = Float64.([Wi1, We1])
        nw = WNUM
        δw = (w1 .- w0) ./ nw

        u = OffsetArray{Float64}(
            undef,
            1-NGU:nu+NGU,
            1-NGV:nv+NGV,
            1-NGW:nw+NGW,
            1:2,
        )
        v = similar(u)
        w = similar(u)
        du = similar(u)
        dv = similar(u)
        dw = similar(u)
        weights = similar(u)

        if TYPE == "rectangle" # rectangular formula
            for l in axes(u, 4),
                k in axes(u, 3),
                j in axes(u, 2),
                i in axes(u, 1)

                u[i, j, k, l] = u0[l] + (i - 0.5) * δu[l]
                v[i, j, k, l] = v0[l] + (j - 0.5) * δv[l]
                w[i, j, k, l] = w0[l] + (k - 0.5) * δw[l]
                du[i, j, k, l] = δu[l]
                dv[i, j, k, l] = δv[l]
                dw[i, j, k, l] = δw[l]
                weights[i, j, k, l] = δu[l] * δv[l] * δw[l]
            end
        elseif TYPE == "newton" # newton-cotes formula
            for l in axes(u, 4),
                k in axes(u, 3),
                j in axes(u, 2),
                i in axes(u, 1)

                u[i, j, k, l] = u0[l] + (i - 0.5) * δu[l]
                v[i, j, k, l] = v0[l] + (j - 0.5) * δv[l]
                w[i, j, k, l] = w0[l] + (k - 0.5) * δw[l]
                du[i, j, k, l] = δu[l]
                dv[i, j, k, l] = δv[l]
                dw[i, j, k, l] = δw[l]
                weights[i, j, k, l] =
                    newton_cotes(i + NGU, UNUM + NGU * 2) *
                    δu[l] *
                    newton_cotes(j + NGV, VNUM + NGV * 2) *
                    δv[l] *
                    newton_cotes(k + NGW, WNUM + NGW * 2) *
                    δw[l]
            end
        else
            throw("No velocity quadrature available")
        end

        # inner constructor method
        new{typeof(u)}(
            u0,
            u1,
            nu,
            v0,
            v1,
            nv,
            w0,
            w1,
            nw,
            u,
            v,
            v,
            du,
            dv,
            dw,
            weights,
        )

    end # constructor

end # struct


"""
Newton-Cotes rule

    newton_cotes(idx::T, num::T) where {T<:Int}

"""
function newton_cotes(idx::T, num::T) where {T<:Int}

    if idx == 1 || idx == num
        nc_coeff = 14.0 / 45.0
    elseif (idx - 5) % 4 == 0
        nc_coeff = 28.0 / 45.0
    elseif (idx - 3) % 4 == 0
        nc_coeff = 24.0 / 45.0
    else
        nc_coeff = 64.0 / 45.0
    end

    return nc_coeff

end
