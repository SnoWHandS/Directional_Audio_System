using PyPlot     # This library is already installed in juliabox 
# (PyPlot takes about 10s to load initially; thereafter it is fast)

Δt = 0.0000125  # time step  (to get Greek sybmol, type \Delta <tab>)
t = 0:Δt:1;  #Define time from 0 to 1s in steps of 0.001s

println("length(t) = ",length(t))

f0 = 1000  # 1000 Hz signal to be modulated
ω0 = 2*pi*f0;   # rad/s   ( Greek symbol \omega <tab>  )
A = 2    #4v p-p

v = A*cos.(ω0*t);   # Create an array holding the sinusoid values

fc = 1000  # 40000 Hz signal for carrier
ωc = 2*pi*fc;   # rad/s   ( Greek symbol \omega <tab>  )
A = 2    #4v p-p

vc = A*cos.(ωc*t).+0im;   # Create an array holding the sinusoid values
vc_sqr = vc.^2
vc_sqr_sqrt = real(vc_sqr.^(1/2))
vc_sqrt = real(vc.^(1/2))           #abs needs a . abs.(array)
#=
figure(1)
plot(t,vc,".-")
xlabel("Time in seconds");
ylabel("Modulation sinusoid 40kHz");
figure(2)
plot(t,v,".-")

xlabel("Time in seconds");
ylabel("sinusoid to be modulated 1kHz");
=#

#Load the PortAudio library
println("Loading library: PortAudio")
@time using PortAudio
# using SampledSignals    # Extra features


#List all audio devices

println("All available audio deviced")
device_list = PortAudio.devices()

for n=1:length(device_list);
   println(device_list[n]);
end


#Open a stream for default audio device_list
stream = PortAudioStream(1, 1, blocksize=1024)
#stream = PortAudioStream(1, 1; samplerate=92000, blocksize=1024)
#Write array to stream
write(stream, v)

println("v written to device")

#Write array to stream
write(stream, real(vc_sqr_sqrt))

println("vc written to device")

# Close the stream
close(stream)