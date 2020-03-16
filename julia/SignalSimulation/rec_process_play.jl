using PortAudio, Statistics, PyPlot, FFTW

stream = PortAudioStream(1, 1, blocksize=1024)

A = 1                       #Amplitude multiple for final output signal
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


#Function for integrating a signal via Riemann sums
function integrate(x, Δt)
    N=length(x)
    y=zeros(N);
    for n=2:N
        y[n]=x[n-1]*Δt + y[n-1]
    end
    return y
end



println("Recording $(Nseconds) seconds of sampled audio")

buf_read = read(stream,N)

println("Processing $(Nseconds) seconds of sampled audio")

#Shift function to above 0 for preprocessing
buf = buf_read #.-minimum(buf_read)

#integrate once with function centered at 0
y1 = integrate(buf.-mean(buf), Δt)
#integrate twice
y2 = integrate(y1.-mean(y1), Δt)

y2 = y2.-mean(y2)

#Shift function to above 0 for preprocessing
buf = y2.-minimum(y2)

#Perform a square root of the samples
buf = sqrt.(buf)

#shift center back to 0 and amplify to be audible
buf = A*buf.-mean(buf)

BUF = fft(buf)
BUF_READ = fft(buf_read)

close("all")

figure(1)
nStart=Int(round(Δt/Δt))
nEnd=Int(round(N*Δt/Δt))
subplot(3,1,1)
plot(t[nStart:nEnd],buf[nStart:nEnd])
xlabel("envelope output")
subplot(3,1,2)
plot(f_axis,abs.(fftshift(BUF)))
xlabel("FFT of envelope")
subplot(3,1,3)
plot(f_axis,abs.(fftshift(BUF_READ)))
xlabel("FFT of original")


println("Playing $(Nseconds) seconds of sampled audio")

write(stream, buf)
close(stream)