using PortAudio

Tsim=10              #1second for simulation
f_samp=44100
Δt=1/f_samp         #seconds: inverse of sample rate
N=Int(round(Tsim/Δt))


f0=500             #Freq of test signal
f1=250
t=(0:N-1)*Δt        #time axis def
ω=2*π*f0            #angular Freq

x=sin.(2*pi*f0*t)               #Create the signgal
y=sin.(2*pi*f1*t)           

#Interleave arrays so Ch1, Ch2, Ch1, Ch2 etc ...
#buf = [x y]'[:]

stream = PortAudioStream(1, 1, blocksize=1024)
#Write array to stream
write(stream, x)

println("buf written to device")

# Close the stream
close(stream)