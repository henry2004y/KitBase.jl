u = collect(-5:0.1:5)

KitBase.ib_briowu(5 / 3, 1.0, 0.5, hcat(u, u))
KitBase.ib_briowu(5 / 3, 1.0, 0.5, ones(8, 8, 2), ones(8, 8, 2))

ib_rh(1.2, 5/3)
