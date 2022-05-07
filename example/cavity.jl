using KitBase

cd(@__DIR__)
ks, ctr, a1face, a2face, simTime = KitBase.initialize("cavity.txt")
simTime = KitBase.solve!(ks, ctr, a1face, a2face, simTime)

# equivalent low-level procedures
using KitBase.ProgressMeter: @showprogress
simTime = 0.0
res = zeros(4)
dt = KitBase.timestep(ks, ctr, simTime)
nt = floor(ks.set.maxTime / dt) |> Int
@showprogress for iter = 1:nt
    KitBase.reconstruct!(ks, ctr)
    KitBase.evolve!(ks, ctr, a1face, a2face, dt; mode = :kfvs, bc = :maxwell)
    KitBase.update!(ks, ctr, a1face, a2face, dt, res; coll = :bgk, bc = :maxwell)
end

# lower-level backend 
@showprogress for iter = 1:nt
    @inbounds Threads.@threads for j = 1:ks.pSpace.ny
        for i = 2:ks.pSpace.nx
            KitBase.flux_kfvs!(
                a1face[i, j].fw,
                a1face[i, j].fh,
                a1face[i, j].fb,
                ctr[i-1, j].h,
                ctr[i-1, j].b,
                ctr[i, j].h,
                ctr[i, j].b,
                ks.vSpace.u,
                ks.vSpace.v,
                ks.vSpace.weights,
                dt,
                ks.ps.dy[i, j],
            )
        end
    end

    # vertical flux
    vn = ks.vSpace.v
    vt = -ks.vSpace.u
    @inbounds Threads.@threads for j = 2:ks.pSpace.ny
        for i = 1:ks.pSpace.nx
            KitBase.flux_kfvs!(
                a2face[i, j].fw,
                a2face[i, j].fh,
                a2face[i, j].fb,
                ctr[i, j-1].h,
                ctr[i, j-1].b,
                ctr[i, j].h,
                ctr[i, j].b,
                vn,
                vt,
                ks.vSpace.weights,
                dt,
                ks.ps.dy[i, j],
            )
            a2face[i, j].fw .= KitBase.global_frame(a2face[i, j].fw, 0.0, 1.0)
        end
    end

    # boundary flux
    @inbounds Threads.@threads for j = 1:ks.pSpace.ny
        KitBase.flux_boundary_maxwell!(
            a1face[1, j].fw,
            a1face[1, j].fh,
            a1face[1, j].fb,
            [1.0, 0.0, 0.0, 1.0],
            ctr[1, j].h,
            ctr[1, j].b,
            ks.vSpace.u,
            ks.vSpace.v,
            ks.vSpace.weights,
            ks.gas.K,
            dt,
            ks.ps.dy[1, j],
            1.0,
        )

        KitBase.flux_boundary_maxwell!(
            a1face[ks.pSpace.nx+1, j].fw,
            a1face[ks.pSpace.nx+1, j].fh,
            a1face[ks.pSpace.nx+1, j].fb,
            [1.0, 0.0, 0.0, 1.0],
            ctr[ks.pSpace.nx, j].h,
            ctr[ks.pSpace.nx, j].b,
            ks.vSpace.u,
            ks.vSpace.v,
            ks.vSpace.weights,
            ks.gas.K,
            dt,
            ks.ps.dy[ks.pSpace.nx, j],
            -1.0,
        )
    end

    @inbounds Threads.@threads for i = 1:ks.pSpace.nx
        KitBase.flux_boundary_maxwell!(
            a2face[i, 1].fw,
            a2face[i, 1].fh,
            a2face[i, 1].fb,
            [1.0, 0.0, 0.0, 1.0],
            ctr[i, 1].h,
            ctr[i, 1].b,
            vn,
            vt,
            ks.vSpace.weights,
            ks.gas.K,
            dt,
            ks.ps.dx[i, 1],
            1,
        )
        a2face[i, 1].fw .= KitBase.global_frame(a2face[i, 1].fw, 0.0, 1.0)

        KitBase.flux_boundary_maxwell!(
            a2face[i, ks.pSpace.ny+1].fw,
            a2face[i, ks.pSpace.ny+1].fh,
            a2face[i, ks.pSpace.ny+1].fb,
            [1.0, 0.0, -0.15, 1.0],
            ctr[i, ks.pSpace.ny].h,
            ctr[i, ks.pSpace.ny].b,
            vn,
            vt,
            ks.vSpace.weights,
            ks.gas.K,
            dt,
            ks.ps.dy[i, ks.pSpace.ny],
            -1,
        )
        a2face[i, ks.pSpace.ny+1].fw .=
            KitBase.global_frame(a2face[i, ks.pSpace.ny+1].fw, 0.0, 1.0)
    end

    # update
    @inbounds Threads.@threads for j = 1:ks.pSpace.ny
        for i = 1:ks.pSpace.nx
            KitBase.step!(
                ctr[i, j].w,
                ctr[i, j].prim,
                ctr[i, j].h,
                ctr[i, j].b,
                a1face[i, j].fw,
                a1face[i, j].fh,
                a1face[i, j].fb,
                a1face[i+1, j].fw,
                a1face[i+1, j].fh,
                a1face[i+1, j].fb,
                a2face[i, j].fw,
                a2face[i, j].fh,
                a2face[i, j].fb,
                a2face[i, j+1].fw,
                a2face[i, j+1].fh,
                a2face[i, j+1].fb,
                ks.vSpace.u,
                ks.vSpace.v,
                ks.vSpace.weights,
                ks.gas.K,
                ks.gas.γ,
                ks.gas.μᵣ,
                ks.gas.ω,
                ks.gas.Pr,
                ks.ps.dx[i, j] * ks.ps.dy[i, j],
                dt,
                zeros(4),
                zeros(4),
                :bgk,
            )
        end
    end
end

# visulization
using Plots
plot(ks, ctr)
#savefig("cavity.png")

# low-level backend
begin
    using Plots
    sol = zeros(4, ks.pSpace.nx, ks.pSpace.ny)
    for i in axes(sol, 2)
        for j in axes(sol, 3)
            sol[1:3, i, j] .= ctr[i, j].prim[1:3]
            sol[4, i, j] = 1.0 / ctr[i, j].prim[4]
        end
    end
    contourf(ks.pSpace.x[1:ks.pSpace.nx, 1], ks.pSpace.y[1, 1:ks.pSpace.ny], sol[4, :, :]')
end
