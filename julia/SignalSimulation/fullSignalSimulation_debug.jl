using PyPlot
using Statistics
using FFTW
using DSP

# make graphs appear outside of julia environment
pygui(true)
show()

#Initialise sampling constants
Tsim=1              #1second for simulation
f_samp=200000       #sample rate of output (artificially high since 40Khz carrier is present)
Δt=1/f_samp         #seconds: inverse of sample rate
N=Int(round(Tsim/Δt))      #The number of samples

#Initialise signal constants
f0=1000         #Audio signal frequency
t=(0:N-1)*Δt    #Define time axis
ω0=2*π*f0        #Define Omega 0 for convenience
fc=40000        #Define the carrier signal's frequency
ωc=2*π*fc        #Define Omega carrier for convenience

#Initialise axis for Fourier transform
Δf=1/(N*Δt)
f=0:(N-1)*Δf
#create array of freq values stored in f_axis. First element maps to 0Hz
if mod(N,2)==0    # case N even
    f_axis = (-N/2:N/2-1)*Δf;    
else   # case N odd
    f_axis = (-(N-1)/2 : (N-1)/2)*Δf; 
end

#Define functions for integrations and differentiation and filtering
#Integration using a Riemann sum integral of the samples
function integrate(x, Δt)
    y=zeros(length(x));
    N = length(x)
    for n=2:N
        y[n]=x[n-1]*Δt + y[n-1]
    end
    return y
end

#Differentiation function implementing a sample wise derivative
function deriv(x,Δt)
    y=zeros(length(x))
    N = length(x)
    for n=2:N
       y[n]=(x[n]-x[n-1])/Δt
    end
    #y[1]=y[2]
    return y
end

#Function to shift a signal backwards by <shift> samples - Will include up to last sample (N)
function shiftBackBy(x,shift)
    yshift=zeros(length(x))
    N = length(x)
    for n=1:N-shift
        yshift[n]=x[n+shift]
    end
    return yshift
end

function rect(t)
    N = length(t)
    result = zeros(N)
    for n=1:N
        abs_t = abs(t[n]);    
        if abs_t > 0.5 
            result[n]=0.0
        elseif abs_t < 0.5 
            result[n]=1.0
        else
            result[n]=0.5
        end
    end
    return result
end

#Generate signals
x=12*sin.(ω0*t)               #create the audio signal
x_carrier=cos.(ωc*t)       #Create the carrier signal
#Pre-process signal             #Perform a double integral to mitigate the double derivative caused by the non-linear medium
y′=integrate(x,Δt)     #perform first integral of the audio signal
#Find median/center and deduct from current value to set it at origin (find missing +C constant to set to origin)
y′=y′.-(mean(y′))
y′′=integrate(y′,Δt)   #perform second integral of the audio signal
#y′′=y′′.-minimum(y′′)           #shifts the signal to above 0
yout = y′′                      #.^(1/2)               #Square root the signal to mitigate the squareing of the non-linear medium
yout_mod=yout                   #.*x_carrier                        #Modulate the preprocessed signal with the 40KHz carrier
#Generate FFTs of the signals (Results more visible)
X=fftshift(abs.(fft(x)))
Y′=fftshift(abs.(fft(y′)))
Y′′=fftshift(abs.(fft(y′′)))
YOUT=fftshift(abs.(fft(yout)))
YOUT_MOD=fftshift(abs.(fft(yout_mod)))
#Plot the signal through its processing chain
close("all")

y′′=shiftBackBy(y′′,2)
y′_derive=(1/10000)*deriv(y′′,Δt)
y′_derive2=(1/10000)*deriv(y′_derive,Δt)
yshift1 = shiftBackBy(y′_derive2,1)

x_int=integrate(x,Δt)
#Find median/center and deduct from current value to set it at origin (find missing +C constant to set to origin)
x_int=x_int.-(mean(x_int))
#x_int=shiftBackBy(x_int,1)

x_int2=integrate(x_int,Δt)
#x_int2=shiftBackBy(x_int2,1)



x_der=deriv(x_int2,Δt)
x_der=shiftBackBy(x_der,1)

x_der2=deriv(x_der,Δt)
x_der2=shiftBackBy(x_der2,1)


figure(5)
#Adjust end points of plot due to discontinuities at start and end
nStart=1#Int(round(0.0001/Δt))
nEnd=Int(round(0.0150/Δt))
plot(t[nStart:nEnd],x[nStart:nEnd], ".")
#plot(t[nStart:nEnd],x_der2[nStart:nEnd], ".")
#plot(t[nStart:nEnd],y′′[nStart:nEnd], ".")
#plot(t[nStart:nEnd],x_int[nStart:nEnd], ".")
plot(t[nStart:nEnd],x_der2[nStart:nEnd], ".")
title("yout in time domain after non-linear demodulation and original waveform")
xlabel("Time (s)")
ylabel("Yout & Vout")



figure(1)
subplot(2,1,1)
plot(f_axis,X)
title("Audio Signal to be processed")
xlabel("Frequency")
ylabel("X(ω)")

subplot(2,1,2)
plot(f_axis,Y′′)
title("Audio Signal with second integral applied")
xlabel("Frequency ω")
ylabel("Y ′′(ω)")

figure(2)
subplot(2,1,1)
plot(f_axis,YOUT)
title("Audio Signal with double integral and square root applied")
xlabel("Frequency ω")
ylabel("Vout(ω)")

subplot(2,1,2)
plot(f_axis,YOUT_MOD)
title("Audio Signal with double integral and square root applied modulated up to 40KHz")
xlabel("Frequency ω")
ylabel("Vout_mod(ω)")

#Simulate the signal in the air with the appropriate governing equation applied to its
yout_mod_sqr = yout_mod             #.^2                      #Square the output



#Create a low pass filter to mimic human hearing
Δω = 2*pi/(N*Δt)                                # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω                               # Define angular frequency 
B = 30000                                       # filter bandwidth of 40KHz to span from -20 to 20 KHz
H = rect.(ω/(2*pi*B)) + rect.( (ω .- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B = __|----|__
Hs=[i[1] for i in H]                            #Change type from Array{Array{Float64,1},1} to Array{Float64,1} so iFFT works

yout_mod_sqr_dt1_lpf = deriv(yout_mod_sqr,Δt)       #Differentiate signal once
yout_mod_sqr_dt1_lpf=shiftBackBy(yout_mod_sqr_dt1_lpf,1)
yout_mod_sqr_dt2 = deriv(yout_mod_sqr_dt1_lpf,Δt)   #Differentiate signal again
yout_mod_sqr_dt2=shiftBackBy(yout_mod_sqr_dt2,1)


#transform function into frequency domain
YOUT_sqr = fft(yout_mod_sqr_dt2)
#Apply filter
YOUT_sqr_LPF = YOUT_sqr.*Hs

yout_demod_sqr_lpf = ifft(YOUT_sqr_LPF)

#transform back to time domain and multiply by 2 (since ifft has 1/2 factor on its result)
#yout_lpf = (2).*ifft(YOUT_LPF)

#Plot outputs
figure(3)
subplot(2,1,1)
plot(f_axis,fftshift(YOUT_sqr))
plot(f_axis,fftshift(Hs))
title("LPF and YOUT in frequency domain")
xlabel("Frequency ω")
ylabel("YOUT_Demod(ω)")
subplot(2,1,2)
plot(f_axis,fftshift(YOUT_sqr_LPF))
title("H x YOUT in frequency domain")
xlabel("Frequency ω")
ylabel("YOUT_LPF(ω)")

figure(4)
#Adjust end points of plot due to discontinuities at start and end
nStart=Int(round(0.45500/Δt))
nEnd=Int(round(0.45700/Δt))
plot(t[nStart:nEnd],yout_demod_sqr_lpf[nStart:nEnd])
title("yout in time domain after non-linear demodulation and original waveform")
plot(t[nStart:nEnd],x[nStart:nEnd])
xlabel("Time (s)")
ylabel("Yout & Vout")

#additionally simulate the bandwidth of the ultrasonic transducers by applying filter to the signal which mimics its -3dB bandwidth