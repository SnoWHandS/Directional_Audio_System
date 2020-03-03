using PyPlot
using Statistics
using FFTW

Tsim=1              #1second for simulation
f_samp=441000
Δt=1/f_samp         #seconds: inverse of sample rate
N=Int(Tsim/Δt)
Tend=(N-1)*Δt

f0=1000
t=(0:N-1)*Δt    #time axis
ω=2*π*f0
fc=40000

x=sin.(2*pi*f0*t)          #ones(N);
x_mean=mean(x)
#x=x.-x_mean

function integrate(x, Δt)
    y=zeros(N);
    for n=2:N
        y[n]=x[n-1]*Δt + y[n-1]
    end
    return y
end

y=integrate(x.-mean(x),Δt)
yy=integrate(y.-mean(y),Δt)

yy=yy.-minimum(yy)       #shifts to above 0

yy_sqrt= yy.^(1/2)

yy_sqrt_mod= yy_sqrt.*cos.(2*pi*fc*t)          #ones(N);

YY_sqrt=fft(yy_sqrt)
YY_mod=fft(yy_sqrt_mod)

#clf()           #Clears figures ()
close("all")    #close all plots

#=
figure(1)
subplot(4,1,1)
plot(t,x)
subplot(4,1,2)
plot(t,y)
subplot(4,1,3)
plot(t,yy)
subplot(4,1,4)
plot(t,yy_sqrt)
=#
Δf=1/(N*Δt)

f=0:(N-1)*Δf
#create array of freq values stored in f_axis. First element maps to 0Hz
if mod(N,2)==0    # case N even
    f_axis = (-N/2:N/2-1)*Δf;    
else   # case N odd
    f_axis = (-(N-1)/2 : (N-1)/2)*Δf; 
end



figure(2)
subplot(2,1,1)
plot(f_axis,fftshift(abs.(YY_sqrt)))
xlabel("YY_sqrt")
subplot(2,1,2)
plot(f_axis,fftshift(abs.(YY_mod)))
xlabel("YY_mod")


yy_mod_sqr = yy_sqrt_mod.^2
YY_mod_sqr = fft(yy_mod_sqr)
figure(3)
subplot(3,1,1)
plot(f_axis,abs.(fftshift(YY_mod_sqr)))
xlabel("YY_mod_sqr")

function deriv(x,Δt)
    y=zeros(length(x))
    for n=2:N
       y[n]=(x[n]-x[n-1])/Δt
    end
    return y
end

yy_mod_sqr_derv = deriv(yy_mod_sqr,Δt)
yy_mod_sqr_derv2 = deriv(yy_mod_sqr_derv,Δt)

YY_mod_sqr_derv1 = fft(yy_mod_sqr_derv)
YY_mod_sqr_derv2 = fft(yy_mod_sqr_derv2)


subplot(3,1,2)
plot(f_axis,abs.(fftshift(YY_mod_sqr_derv1)))
xlabel("fft of sqr single derivative")
subplot(3,1,3)
plot(f_axis,abs.(fftshift(YY_mod_sqr_derv2)))
xlabel("fft of sqr double derivative")


#Low pass filter the output to mimic human hearing

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

Δω = 2*pi/(N*Δt)   # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω
B = 20000 # filter bandwidth

H = rect.(ω/(2*pi*B)) + rect.( (ω .- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B

#apply LPF
YY_mod_sqr_derv2_LPF = (YY_mod_sqr_derv2).*H

#yout=ifft(YY_mod_sqr_LPF)

figure(4)
subplot(3,1,1)
plot(f_axis,fftshift(H))
xlabel("Low pass filter")
subplot(3,1,2)
plot(f_axis,abs.(fftshift(YY_mod_sqr_derv2)))
xlabel("FFT of signal")
subplot(3,1,3)
plot(f_axis,fftshift(YY_mod_sqr_derv2_LPF))
xlabel("H x YY")

#=
figure(5)
subplot(2,1,1)
plot(t,x)
xlabel("output from filter")
subplot(2,1,2)
plot(t,x)
xlabel("Original function")=#