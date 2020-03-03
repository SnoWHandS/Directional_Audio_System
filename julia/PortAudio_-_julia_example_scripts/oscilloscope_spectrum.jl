
# Real time oscilloscope, FFT and waterfall FFT display
# AJW  2017-04-17  (edited 2019-08-12)
# I added double buffering mode
# Plot a real-time spectrogram (orginal code)
# see https://github.com/JuliaAudio/PortAudio.jl
# Note:  For Julia 1.x, one has to use the development code version:
#  Pkg.add("PortAudio#julia1")   
# This code was adapted from one of the PortAudio examples.

println("Loading libraries (... wait a minute)")
using Plots, PortAudio, SampledSignals
using DSP
using FFTW

# Turn on double buffering to avoid flicker
ENV["GKS_DOUBLE_BUF"]="true"

default(size=(1000,700), leg=false)  # Windows size; no legends

gr()   # GR plot library is very fast
#pyplot()   # PyPlot is slow

const N = 1024
const stream = PortAudioStream(1, 0, blocksize=N)
const buf = read(stream, N)
const fmin = 0Hz
const fmax = 5000Hz
const fs = Float32[float(f) for f in domain(fft(buf)[fmin..fmax])]

g = buf[1:Int64(N/2)]
const ffs = Float32[float(f) for f in domain(fft(g)[fmin..fmax])]

# Define a matrix in which to store scrolling waterfall FFT data
M=Int64(N/2)
Cols=length(ffs)
Rows=20
matrix = zeros(Rows,Cols)

N_iterations = 200
println("N_iterations = $(N_iterations)")

for i=1:N_iterations

    read!(stream, buf)   # Capture some audio

#    plot(fs, abs(fft(buf)[fmin..fmax]), xlim=(fs[1],fs[end]), ylim=(0,100))

    #plot(buf)
    #d = buf

   data = buf*100   # Scale the values so that they in range -20:20

   thresh = 0  # Define an oscilloscope threshold on which to triggered

   # Scan through recording (up to N/2) until first instance of triggered
   triggered=true
   n = 1
   while n<=N/2 && triggered==false
     if (data[n]<thresh && data[n+1]>thresh)
       triggered=true
     end
     n=n+1
   end

   if triggered==true   # If triggered

     g = data[n:Int64(n+N/2-1)];   # Extract N/2 samples from triggered point


#  plt = plot([g,fftshift(abs.(fft(g)))], layout = (2,1))
#  plt = plot([1:length(g),fs],[g,abs.(fft(g)[fmin..fmax])], layout = (2,1))
   #  plt = plot([1:M,ffs],[g,abs.(fft(g)[fmin..fmax])], ylim=(-20,20), layout = (3,1))

     win = hanning(length(g));

     # Calculate FFT and extract relevant portion from fmin..fmax
     G = abs.(fft(g.*win)[fmin..fmax] /M*2);  # Scale such that Acos(wt) has peak A.

     # Update matrix
     matrix[2:Rows,:] = matrix[1:Rows-1,:];  # Shift down
     matrix[1,1:Cols] = G;

     # Create three displays
     plt = plot(
               plot([1:M],g,ylim=(-10,10)),
               plot(ffs,G,ylim=(0,10)),
               # plot(G) ,
		#plot(abs(fft([g.*win;zeros(length(g)*10)])[fmin..fmax]),ylim=(0,1000)), # Need to fix freq label
                contourf(matrix,colorbar=false),
                layout = (3,1)
           )
#     plt = plot( plot([1:M],g,ylim=(-10,10)), plot(ffs,G,ylim=(0,10)), surface(matrix), layout = (3,1) )

     display(plt)  # Update the display (I think that)

   end
end

close(stream)
