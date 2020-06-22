using Statistics, FFTW, SampledSignals, PyPlot, DSP, PortAudio
using FileIO: load, save, loadstreaming, savestreaming
using LibSndFile


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


stereo_buf_read = load(joinpath(homedir(), "OneDrive", "2020", "Research_Project", "Testing", "Rhode_mic", "Distortion", "SQRT2.wav"))

buf_read = stereo_buf_read[:,1]     #convert to mono

sample_rate = 44100
Nseconds = length(buf_read)/sample_rate

#extract only the sweep
buf_read = buf_read


N = Int(round(Nseconds * sample_rate))
Δt=1/sample_rate                 #seconds: inverse of sample rate
t=(0:N-1)*Δt                    #time axis def
#Define f_axis
Δf=1/(N*Δt)
f=0:(N-1)*Δf
#create array of freq values stored in f_axis. First element maps to 0Hz
if mod(N,2)==0    # case N even
    f_axis = (-N/2:N/2-1)*Δf;    
else   # case N odd
    f_axis = (-(N-1)/2 : (N-1)/2)*Δf; 
end


BUF_fft = fft(buf_read)
close("all")


figure(1)
subplot(2,1,1)
plot(t,buf_read)
title("Original recorded signal")
xlabel("time (s)")
ylabel("amplitude (v)")
subplot(2,1,2)
plot(f_axis,fftshift(abs.(BUF_fft)))
#plot(f_axis,fftshift(abs.(Hs)))
title("FFT of recorded signal")
xlabel("frequency (Hz)")
ylabel("relative magnitude")

figure(2)
plot(f_axis[Int(round(length(f_axis)/2)):end],fftshift(abs.(BUF_fft))[Int(round(length(BUF_fft)/2)):end])
title("FFT of signal, positive frequencies")
xlabel("frequency (Hz)")
ylabel("relative magnitude")