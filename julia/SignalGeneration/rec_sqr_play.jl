using PortAudio, Statistics, PyPlot, FFTW

stream = PortAudioStream(1, 1, blocksize=1024)

offset = 20

A = 1#4.75                       #Amplitude multiple for final output signal
sample_rate = 44100
Nseconds = 1
N = Nseconds * sample_rate
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


#Function for high pass filtering a time domain
function hpf(in_signal, time_step, cutoff_freq)
    out_signal = Array{Float64}(undef, length(in_signal));
    RC = 1/(2*pi*cutoff_freq);
    a = RC/(RC + time_step);
    out_signal[1] = in_signal[1]
    for i = 2:length(in_signal)
        out_signal[i] = a*(out_signal[i-1] + in_signal[i] - in_signal[i-1]);
    end;
    return out_signal;
end;

function removeClipping(inputBuf)
    for i=1:length(inputBuf);
        if inputBuf[i] > 1
            inputBuf[i]=1
        end
        if inputBuf[i] < -1
            inputBuf[i] = -1
        end
    end
    return inputBuf
end

println("Recording $(Nseconds) seconds of sampled audio")

#buf_read = read(stream,N)
f0 = 2500  # 1000 Hz signal to be modulated
ω0 = 2*pi*f0;   # rad/s   ( Greek symbol \omega <tab>  )
A = 1    #2v p-p

buf_read = A*cos.(ω0*t);   # Create an array holding the sinusoid values
const buf = buf_read

println("Processing $(Nseconds) seconds of sampled audio")

#Shift function to above 0 for preprocessing
buf = buf_read.-minimum(buf_read)

#Perform a square root of the samples
buf = sqrt.(buf)

#filter away DC
buf = hpf(buf,Δt,75)

#shift center back to 0 and amplify to be audible
hpfmin=minimum(buf)
hpfmax=maximum(buf)

buf = A*buf
#remove clipping
buf = removeClipping(buf)

BUF = fft(buf)
BUF_READ = fft(buf_read)

close("all")
figure(1)
nStart=Int(round(0.01/Δt))        #Artifact with samples before 0.0025s = 2.5ms
nEnd=Int(round(0.02/Δt))
subplot(2,1,1)

plot(t[nStart:nEnd],buf_read[nStart:nEnd])
title("original output")
xlabel("time (s)")
ylabel("Audio Out (V)")
subplot(2,1,2)
plot(t[nStart:nEnd],buf[nStart:nEnd])
title("envelope output")
xlabel("time (s)")
ylabel("Audio Out (V)")

figure(2)
subplot(2,1,1)
plot(f_axis,abs.(fftshift(BUF_READ)))
title("FFT of original")
xlabel("Frequency (Hz)")
ylabel("Relative magnitude")
subplot(2,1,2)
plot(f_axis,abs.(fftshift(BUF)))
title("FFT of output")
xlabel("Frequency (Hz)")
ylabel("Relative magnitude")


println("Playing $(Nseconds) seconds of sampled audio")

write(stream, buf)
close(stream)