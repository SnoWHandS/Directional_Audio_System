
# Real time oscilloscope, FFT and waterfall FFT display
# AJW  2017-04-17
# I added double buffering
# Plot a real-time spectrogram (orginal code)
# see https://github.com/JuliaAudio/PortAudio.jl


using PyPlot, PortAudio, SampledSignals

# Turn on double buffering to avoid flicker
ENV["GKS_DOUBLE_BUF"]="true"

#using Plots
#gr();
#default(size=(1000,700), leg=false)  # Windows size; no legends


const N = 1024
const stream = PortAudioStream(1, 0, blocksize=N) #One input only
const buf = read(stream, N)
const fmin = 0Hz
const fmax = 5000Hz
const fs = Float32[float(f) for f in domain(fft(buf)[fmin..fmax])]

#List all audio devices

device_list = PortAudio.devices()

for n=1:length(device_list);
   println(device_list[n]);
end


#Line below does not work
#PortAudioStream(inchans=2, outchans=2; eltype=Float32, samplerate=48000Hz, blocksize=4096, synced=false)

stream = PortAudioStream(2, 2, eltype=Float32, samplerate=48000, blocksize=4096, synced=false)

# Record a few seconds
duration = 2s;
buf = read(stream, duration)

# Plot sampled time waveform
figure(); plot(domain(buf),buf)  # domain(buf) creates time axis
title("Sampled time-domain signal")

# Plot FFT
BUF = fft(buf)
figure(); plot(domain(BUF),abs(BUF))  # domain(buf) creates time axis
title("Sampled frequency-domain signal")




