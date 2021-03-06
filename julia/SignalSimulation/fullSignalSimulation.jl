using PyPlot
using Statistics
using FFTW
using DSP

# make graphs appear outside of julia environment
pygui(true)
show()

#Initialise sampling constants
Tsim=0.05              #1second for simulation
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
y′=integrate(x.-mean(x),Δt)     #perform first integral of the audio signal
y′′=integrate(y′.-mean(y′),Δt)   #perform second integral of the audio signal
#y′′=integrate(y′,Δt)
y′′=y′′.-minimum(y′′)           #shifts the signal to above 0
yout = y′′.^(1/2)               #Square root the signal to mitigate the squaring of the non-linear medium
yout_mod=yout.*x_carrier        #Modulate the preprocessed signal with the 40KHz carrier
#Generate FFTs of the signals (Results more visible)
X=fftshift(abs.(fft(x)))
Y′=fftshift(abs.(fft(y′)))
Y′′=fftshift(abs.(fft(y′′)))
YOUT=fftshift(abs.(fft(yout)))
YOUT_MOD=fftshift(abs.(fft(yout_mod)))
#Plot the signal through its processing chain
close("all")

figure(1)


#=subplot(2,1,1)
plot(f_axis,X)
title("FFT of Audio Signal to be processed")
xlabel("Frequency")
ylabel("X(ω)")
=#

subplot(2,1,1)
plot(f_axis[Int(round(length(f_axis)/2)):end],Y′[Int(round(length(Y′)/2)):end])
title("FFT of Audio Signal with first integral applied")
xlabel("Frequency ω")
ylabel("Y ′(ω)")

subplot(2,1,2)
plot(f_axis[Int(round(length(f_axis)/2)):end],Y′′[Int(round(length(Y′′)/2)):end])
title("FFT of Audio Signal with second integral applied")
xlabel("Frequency ω")
ylabel("Y ′′(ω)")



figure(2)
#=subplot(2,1,1)
plot(t,y′)
title("Audio Signal with first integral applied")
xlabel("time (t)")
ylabel("y ′(t)")

subplot(2,1,2)
plot(t,y′′)
title("Audio Signal with second integral applied")
xlabel("time (t)")
ylabel("y ′′(t)")
=#
subplot(2,1,1)
plot(f_axis[Int(round(length(f_axis)/2)):end],YOUT[Int(round(length(YOUT)/2)):end])
title("Audio Signal with double integral and square root applied")
xlabel("Frequency ω")
ylabel("Vout(ω)")

subplot(2,1,2)
plot(f_axis[Int(round(length(f_axis)/2)):end],YOUT_MOD[Int(round(length(YOUT_MOD)/2)):end])
title("Audio Signal with double integral and square root applied modulated up to 40KHz")
xlabel("Frequency ω")
ylabel("Vout_mod(ω)")

#Simulate the signal in the air with the appropriate governing equation applied to its
yout_mod_sqr = yout_mod.^2                      #Square the output



#Create a low pass filter to mimic human hearing
Δω = 2*pi/(N*Δt)                                # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω                               # Define angular frequency 
B = 30000                                       # filter bandwidth of 40KHz to span from -20 to 20 KHz
H = rect.(ω/(2*pi*B)) + rect.( (ω .- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B = __|----|__
Hs=[i[1] for i in H]                            #Change type from Array{Array{Float64,1},1} to Array{Float64,1} so iFFT works

#transform function into frequency domain
YOUT_sqr = fft(yout_mod_sqr)
#Apply filter
YOUT_sqr_LPF = YOUT_sqr.*Hs

yout_mod_sqr_lpf = 2*real(ifft(YOUT_sqr_LPF))   #Extract  time-domain

yout_mod_sqr_dt1_lpf = deriv(yout_mod_sqr_lpf,Δt)       #Differentiate signal once
yout_mod_sqr_dt1_lpf = shiftBackBy(yout_mod_sqr_dt1_lpf,1)
yout_mod_sqr_dt2 = deriv(yout_mod_sqr_dt1_lpf,Δt)   #Differentiate signal again
yout_mod_sqr_dt2 = shiftBackBy(yout_mod_sqr_dt2,1)

YDT1 = fftshift(abs.(fft(yout_mod_sqr_dt1_lpf)))
YDT2 = fftshift(abs.(fft(yout_mod_sqr_dt2)))
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
nStart=Int(round(Δt/Δt))
nEnd=Int(round(0.0060/Δt))
plot(t[nStart:nEnd],yout_mod_sqr_dt2[nStart:nEnd], ".")
title("yout in time domain after non-linear demodulation and original waveform")
plot(t[nStart:nEnd],x[nStart:nEnd], ".")
xlabel("Time (s)")
ylabel("Yout & Vout")

figure(5)
subplot(2,1,1)
plot(t[nStart:nEnd],yout_mod_sqr_dt1_lpf[nStart:nEnd], ".")
plot(t[nStart:nEnd],(1/500)*x[nStart:nEnd], ".")
title("yout in time domain after first derivative and original waveform")
xlabel("Time (s)")
ylabel("Yout & Vout")
subplot(2,1,2)
plot(t[nStart:nEnd],yout_mod_sqr_dt2[nStart:nEnd], ".")
plot(t[nStart:nEnd],(1/10)*x[nStart:nEnd], ".")
title("yout in time domain after non-linear demodulation and original waveform")
xlabel("Time (s)")
ylabel("Yout & Vout")

#=
plot(f_axis,YDT1)
title("signal after first derivative in frequency domain")
xlabel("Frequency ω")
ylabel("Yout_DT1(ω)")
subplot(2,1,2)
plot(f_axis,YDT2)
title("signal after second derivative in frequency domain")
xlabel("Frequency ω")
ylabel("Yout_DT2(ω)")=#

#additionally simulate the bandwidth of the ultrasonic transducers by applying filter to the signal which mimics its -3dB bandwidth