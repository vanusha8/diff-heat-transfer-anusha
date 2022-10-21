# using Plots
using LinearAlgebra
using ForwardDiff
using DelimitedFiles

function heat_transfer()
    # box size, m
    w = h = 1
    # intervals in x-, y- directions, m
    dx = dy = 0.005
    # Thermal conductivity W/(m-K)
    thermal_conductivity = 1.602 
    # Thermal diffusivity, m2.s-1
    alphaSoil =  1.97e-7  # m^2/s
    alphaSteel = 2.3e-5   # m^2/s
    alphaWater = 1.39e-7  # m^2/s
    # Porosity
    n = 0.45

    # Viscosity kg/m
    mu = 1.00E-03 
    # Permeability m2
    k = 1.0E-12
    # Thermal expansion 
    beta = 8.80E-05
    # Cf
    cf = 4290
    # rhow
    rhow = 980
    # gravity
    g = 9.81 

    # Set conduction to 0 to disable
    conduction = 1.
    convection = 1.

    # Temperature of the cable
    Tcool, Thot = 0, 30

    # pipe geometry
    pr, px, py = 0.0125, 0.5, 0.5
    pr2 = pr^2

    # Calculations
    nx, ny = convert(Int64, w/dx), convert(Int64, h/dy)
    dx2, dy2 = dx*dx, dy*dy

    dt = 0.5    

    alpha = alphaSoil
    u0 = Tcool * ones(nx, ny)
    
    # Initial conditions
    for i = 97:103
        for j = 97:103
            if ((i*dx-px)^2 + (j*dy-py)^2) <= pr2
                u0[i,j] = Thot
            end
        end
    end

    # Copy to u
    u = deepcopy(u0)

    nsteps = 100000
    convection_factor = convection * dt * (1/(n*mu)*k*g*rhow) / dy
    # Iterate
    for k = 1:nsteps
        for i = 2:nx-1
            for j = 2:ny-1
                # The velocity corresponds to differential density, since we are measuring the differnetial temp,
                # the rho(1 - beta(T)) is written as rho*(beta*DeltaT) cable
                u[i, j] = u0[i, j] +
                    conduction * dt * alphaSoil * ((u0[i+1, j] - 2 * u0[i,j] + u0[i-1, j])/dy2 + 
                                               (u0[i, j+1] - 2 * u0[i,j] + u0[i, j-1])/dx2) + 
                    (u0[i-1,j] - u0[i,j]) * convection_factor * (1 - beta * u0[i,j])
            end
        end
        # Initial conditions
        for i = 97:103
            for j = 97:103
                if ((i*dx-px)^2 + (j*dy-py)^2) <= pr2
                    u[i,j] = Thot
                end
            end
        end

        u0 = copy(u)
    end
    writedlm("u0.csv",  u0, ',')
    println("Constant: ", convection_factor)
end


heat_transfer()
println("Completed heat transfer sim")