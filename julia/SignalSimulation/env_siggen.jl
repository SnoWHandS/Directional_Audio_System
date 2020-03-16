using PyPlot
using Statistics
using FFTW
using PortAudio

Tsim=3              #1second for simulation
f_samp=44100
Δt=1/f_samp         #seconds: inverse of sample rate
N=Int(round(Tsim/Δt))


f0=5000             #Freq of test signal
t=(0:N-1)*Δt        #time axis def
ω=2*π*f0            #angular Freq

A=10000                #scaling factor for envelope function

Δf=1/(N*Δt)
f=0:(N-1)*Δf
#create array of freq values stored in f_axis. First element maps to 0Hz
if mod(N,2)==0    # case N even
    f_axis = (-N/2:N/2-1)*Δf;    
else   # case N odd
    f_axis = (-(N-1)/2 : (N-1)/2)*Δf; 
end

function integrate(x, Δt)
    N=length(x)
    y=zeros(N);
    for n=2:N
        y[n]=x[n-1]*Δt + y[n-1]
    end
    return y
end


close("all")    #close all plots

x=sin.(2*pi*f0*t)               #Create the signgal
x_mean=mean(x)                  #Find average of signal

y′=integrate(x.-mean(x),Δt)     #first integral
y′′=integrate(y′.-mean(y′),Δt)   #second integral
y′′=y′′.-minimum(y′′)              #shifts to above 0

y_env = A*y′′.^(1/2)
#y_env = y_env.-mean(y_env)
Y_env = fft(y_env)

figure(1)
nStart=Int(round(0.04/Δt))
nEnd=Int(round(0.04580/Δt))
subplot(3,1,1)
plot(t[nStart:nEnd],y_env[nStart:nEnd])
xlabel("envelope output")
subplot(3,1,2)
plot(f_axis,abs.(fftshift(Y_env)))
xlabel("FFT of envelope")

stream = PortAudioStream(1, 1, blocksize=1024)
#Write array to stream
write(stream, y_env)

println("v_env written to device")

# Close the stream
close(stream)