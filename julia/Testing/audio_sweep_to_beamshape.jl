using Statistics, FFTW, SampledSignals, PyPlot, DSP, PortAudio
using FileIO: load, save, loadstreaming, savestreaming
using LibSndFile

#Creates a rectangular function for FIR filtering
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

function rollingFFT(tdomSig, winSize, step)
#Translates a time domain signal to a array of FFTs over time
    sigN = length(tdomSig)                      #Number of time domain samples
    elements = Int(floor(sigN/step))            #number of samples div by number of steps = number of FFTs
    elements = elements - Int(ceil(winSize/step))        #fix off by one
    halfWindow = Int(round(winSize/2))
    spectrogram = zeros(halfWindow,elements)       #array of FFTs of y winSize and x elements
    
    for i=1:elements
        window = tdomSig[1 + (i-1)*step : (i-1)*step + winSize ]
        window = window .- mean(window)
        spectrogram[:,i] = abs.(fft(window)[1:halfWindow])    # : = all rows for a particular column (i) 
    end
    return spectrogram
end
    

stereo_buf_read = load(joinpath(homedir(), "OneDrive", "2020", "Research_Project", "Testing", "Rhode_mic", "Beam_sweeps", "usonic_Samsonmic_t6_good34s.wav"))

buf_read = stereo_buf_read[:,1]     #convert to mono

sample_rate = 44100

tstart_sweep = 35
tend_sweep = 56
nstart_sweep = tstart_sweep*sample_rate
nend_sweep = tend_sweep*sample_rate

#extract only the sweep
buf_read = buf_read[nstart_sweep:nend_sweep]

Nseconds = length(buf_read)/sample_rate
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




#Create a lowpass filter to find only the tone of interest
Δω = 2*pi/(N*Δt)                                # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω                               # Define angular frequency 
bpf_centerf = 2500
ω0 = 2*pi*bpf_centerf                                  # Define angular frequency to shift by 
B = 100                                       # filter bandwidth of 40KHz to span from -20 to 20 KHz
Hpos = rect.((ω.-ω0)/(2*pi*B))
Hneg = rect.( ((ω .+ω0).- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B = __|----|__
Hs = Hpos + Hneg
Hs=[i[1] for i in Hs]                            #Change type from Array{Array{Float64,1},1} to Array{Float64,1} so iFFT works

BUF_fft = fft(buf_read)

#apply filter
BUF_flt = BUF_fft.*Hs

buf_flt = ifft(BUF_flt)

#buf_read_sin = buf_read + cos.(2*pi*1000*t)

windSize = Int(round(0.04/Δt))
stepSize = Int(round(0.04/Δt))
spectro = rollingFFT(buf_flt, windSize, stepSize)

close("all")
nStart=Int(round(Δt/Δt))        #Artifact with samples before 0.0025s = 2.5ms
nEnd=Int(round(N*Δt/Δt))
figure(1)
spectroLog = 20*log10.(spectro)
Δf_spectro=1/(windSize*Δt)
halfF_Axis=0:(size(spectroLog)[1] - 1)*Δf_spectro
imshow(spectroLog, aspect = "auto", origin = "lower" ,extent = [0, Nseconds, halfF_Axis[1],halfF_Axis[end]])
title("filtered spectrogram of signal with bandpass at 7.5kHz (100Hz BW). Left to right sweep")
xlabel("time (s)")
ylabel("frequency (Hz)")

figure(2)
plot(t,buf_flt)
title("filtered time domain signal with bandpass at 7.5kHz (100Hz BW). Left to right sweep")
xlabel("time (s)")
ylabel("amplitude (v)")

figure(3)
subplot(2,1,1)
plot(t[nStart:nEnd],buf_read[nStart:nEnd])
title("Original recorded signal. Left to right sweep")
xlabel("time (s)")
ylabel("amplitude (v)")
subplot(2,1,2)
plot(f_axis,fftshift(abs.(BUF_fft)))
#plot(f_axis,fftshift(abs.(Hs)))
title("FFT of recorded signal. Left to right sweep")
xlabel("frequency (Hz)")
ylabel("relative magnitude")

figure(4)
plot(f_axis,fftshift(abs.(BUF_flt)))
title("FFT of filtered signal. Left to right sweep")
xlabel("frequency (Hz)")
ylabel("relative magnitude")

figure(5)
plot(f_axis[Int(round(length(f_axis)/2)):end],fftshift(abs.(BUF_fft))[Int(round(length(BUF_fft)/2)):end])
title("FFT of signal, positive frequencies")
xlabel("frequency (Hz)")
ylabel("relative magnitude")