using Statistics, GR, FFTW, SampledSignals
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


stereo_buf_read = load(joinpath(homedir(), "OneDrive", "2020", "Research_Project", "Testing", "50cm.wav"))

buf_read = stereo_buf_read[:,1]     #convert to mono

sample_rate = 48000
Nseconds = length(buf_read)/48000
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


#Create a bandpass filter to find only the tone of interest
Δω = 2*pi/(N*Δt)                                # Sample spacing in freq domain in rad/s
ω = 0:Δω:(N-1)*Δω                               # Define angular frequency 
B = 500                                       # filter bandwidth of 40KHz to span from -20 to 20 KHz
H = rect.(ω/(2*pi*B)) + rect.( (ω .- 2*pi/Δt)/(2*pi*B) )    #rect at w/B + rect at w-t/B = __|----|__
Hs=[i[1] for i in H]                            #Change type from Array{Array{Float64,1},1} to Array{Float64,1} so iFFT works


const fmin = 0Hz
const fmax = 10000Hz
const fs = Float32[float(f) for f in domain(fft(buf_read)[fmin..fmax])]

global tlim = 0

while tlim<Nseconds
    #read!(stream, buf)
    plot(fs, abs.(fft(buf_read)[fmin..fmax])) #, xlim=(fs[1],fs[end]), ylim=(0,100)
    sleep(Δt)
    tlim = tlim+Δt
end

BUF_fft = fft(buf_read)

close("all")
nStart=Int(round(Δt/Δt))        #Artifact with samples before 0.0025s = 2.5ms
nEnd=Int(round(N*Δt/Δt))


subplot(2,1,1)
plot(t[nStart:nEnd],buf_read[nStart:nEnd])
xlabel("original input")
subplot(2,1,2)
plot(f_axis,fftshift(abs.(BUF_fft)))
xlabel("FFT of input")