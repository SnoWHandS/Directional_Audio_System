using PyPlot        #for plotting
using QuadGK

#using Cubature      #for integration
#using Cuba          #Integration
#If not installed, uncomment the following
#=using Pkg
Pkg.add("PyPlot")
Pkg.add("Cubature")=#


Δt = 0.0000125  # time step  (to get Greek sybmol, type \Delta <tab>)
t = -0.002:Δt:0.002;  #Define time from 0 to 0.001s in steps of 0.0000125s

println("length(t) = ",length(t))

f0 = 1000  # 1000 Hz signal to be modulated
ω0 = 2*pi*f0;   # rad/s   ( Greek symbol \omega <tab>  )
A = 2    #4v p-p

v = A*sin.(ω0*t);   # Create an array holding the sinusoid values
v1 = A*t.^2
v1_int, err = quadgk(t->v1,-0.002,0.002)
v_integ, err = quadgk(t->v, 0, 1)

#Integration types:
    #h-adaptive = good for functions with sharp features or discontinuities (peaks, kinks) as it adaptively adds more points in these regions
        #good for unknown/under-defined functions
        #Works at the interior of the domain, not the edges
    #p-adaptive = good for smooth, continous functions (infinitely differentiable) with low dimensions (1 or 2); achieves high accuracy
        #Works throughout the domain (incl. edges)
#(v_integ, err) = hquadrature(1, (f,t) -> t[:] = A*cos.(ω0*t), 0, 0.002)
#(v_integ, err) = hquadrature(1,v,0,0.002)

#Testing Cuba integration can use llcuhre for 64bit
#println(cuhre(((t, f)->f[1]=A*sin.(ω0*t[1]))))


#Plot the original waveform
figure(1)
plot(t,v1,".-")
xlabel("Time in seconds")
ylabel("sinusoid to be modulated 1kHz")

#Plot the integrated waveform
figure(2)
plot(t,v1_int,".-")
xlabel("Time in seconds")
ylabel("Integrated sinusoid to be modulated 1kHz")