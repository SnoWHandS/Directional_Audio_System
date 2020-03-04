using PyPlot
using Statistics
using FFTW

#Initialise sampling constants
Tsim=1              #1second for simulation
f_samp=101100       #sample rate of output (artificially high since 40Khz carrier is present)
Δt=1/f_samp         #seconds: inverse of sample rate
N=Int(Tsim/Δt)      #The number of samples

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
    for n=2:N
        y[n]=x[n-1]*Δt + y[n-1]
    end
    return y
end

#Differentiation function implementing a sample wise derivative
function deriv(x,Δt)
    y=zeros(length(x))
    for n=2:N
       y[n]=(x[n]-x[n-1])/Δt
    end
    return y
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
x=sin.(ω0*t)               #create the audio signal
x_carrier=cos.(ωc*t)       #Create the carrier signal
#Pre-process signal             #Perform a double integral to mitigate the double derivative caused by the non-linear medium
y′=integrate(x.-mean(x),Δt)     #perform first integral of the audio signal
y′′=integrate(y′.-mean(y′),Δt)   #perform second integral of the audio signal
y′′=y′′.-minimum(y′′)           #shifts the signal to above 0
yout = y′′.^(1/2)               #Square root the signal to mitigate the squareing of the non-linear medium

#Plot the signal through its processing chain
close("all")

figure(1)
subplot(2,1,1)
plot(t,x)
title("Audio Signal to be processed")
xlabel("t")
ylabel("x")

subplot(2,1,2)
plot(t,y′)
title("Audio Signal with first integral applied")
xlabel("t")
ylabel("y ′")

figure(2)
subplot(2,1,1)
plot(t,y′′)
title("Audio Signal with second integral applied")
xlabel("t")
ylabel("y ′′")

subplot(2,1,2)
plot(t,yout)
title("Audio Signal with double integral and square root applied")
xlabel("t")
ylabel("V out")

#Simulate the signal in the air with the appropriate governing equation applied to its
yout_mod=yout.*x_carrier                        #Modulate the preprocessed signal with the 40KHz carrier
yout_mod_sqr = yout_mod.^2                      #Square the output
yout_mod_sqr_dt1 = deriv(yout_mod_sqr,Δt)       #Differentiate signal once
yout_mod_sqr_dt2 = deriv(yout_mod_sqr_dt1,Δt)   #Differentiate signal again

#Create a low pass filter to mimic human hearing
Δω = 2*pi/(N*Δt)                                # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω
B = 40000                                       # filter bandwidth of 40KHz to span from -20 to 20 KHz
H = rect.(ω/(2*pi*B)) + rect.( (ω .- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B

#transform function into frequency domain
YOUT_Demod = abs.(fft(yout_mod_sqr_dt2))
#Apply filter
YOUT_LPF = YOUT_Demod.*H
#transform back to time domain
#yout_lpf = ifft(YOUT_LPF)

#Plot outputs
figure(3)
subplot(2,1,1)
plot(f_axis,fftshift(YOUT_LPF))
title("H x YOUT in frequency domain")

#subplot(2,1,2)
#plot(t,yout_lpf)
#title("yout in time domain")