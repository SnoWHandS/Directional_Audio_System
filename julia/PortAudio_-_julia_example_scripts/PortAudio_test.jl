# RECORDING AND PLAYING SOUND USING PortAudio library
# Tested only on Ubuntu Linux Version with Julia 1.04 (it currently fails on Julia 1.2  2019-09-13)
# The default PortAudio package has not been updated for Julia 1.
# https://github.com/JuliaAudio/PortAudio.jl/issues/34
# You can however install the Julia 1 development version of package as follows:
# using Pkg; 
# Pkg.add("PortAudio#julia1"); 
# Pkg.add("RingBuffers#master");
# Pkg.build("RingBuffers");
# Pkg.build("PortAudio")
# For extra features
# Pkg.add("SampledSignals#master")
# Pkg.add("LibSndFile")
# I managed to get it to install and work on Ubuntu Linux 19.
# See examples in  .julia/packages/PortAudio/.../examples
# AJW 2019-08-19


println("Loading library: PortAudio")
@time using PortAudio
# using SampledSignals    # Extra features


#List all audio devices

println("All available audio deviced")
device_list = PortAudio.devices()

for n=1:length(device_list);
   println(device_list[n]);
end

# Parameters: Device, number of sources (inputs), number of sinks (outputs)
# stream = PortAudioStream("HDA Intel PCH: ALC269VC Analog (hw:0,0)", 2, 2)

# One input channel (mic), two output (speakers)
#stream = PortAudioStream("HDA Intel PCH: ALC269VC Analog (hw:0,0)", 1, 2)  # Works on my Samsung NP900X3C laptop
# PortAudioStream{Float32}
#  Samplerate: 44100.0Hz
#  Buffer Size: 4096 frames
#  2 channel sink: "HDA Intel PCH: ALC269VC Analog (hw:0,0)"
#  1 channel source: "HDA Intel PCH: ALC269VC Analog (hw:0,0)"

println("Opening a stream, linked to the default audio device")
println("You should turn up volume using the standard audio settings")
stream = PortAudioStream(1, 1, blocksize=1024)  # Also works (uses default stream)
# For one speaker output only ( 
# stream = PortAudioStream(1, 1, blocksize=1024)  # Also works (uses default stream)

# Read a few seconds of audio from the mic
sample_rate = 44100
Nseconds = 3
Nsamples = Nseconds * sample_rate

println("Recording $(Nseconds) seconds of audio")

buf = read(stream,Nsamples)

# Alternatively, if SamplesSignals is loaded, then one can specify directly the recording time in seconds e.g. "3s":
#buf = read(stream, 3s)


# Play it
println("Playing the $(Nseconds) of recorded audio - you should hear it!")
write(stream, buf)

# Note: to start a parallel thread, use the macro "@async"
# This make the call a "non-blocking" operation.
# e.g.   
# @async write(stream, buf)
# Note, the following also works:
# buf = read(stream.source, 3s)
# write(stream.sink, buf)

# Plot 
println("Loading library: PyPlot")
using PyPlot

figure()
plot(buf)


# Save to a file
println("Loading other libraries to allow saving the audio to an .ogg file:")
using FileIO: load, save, loadstreaming, savestreaming
using LibSndFile

# See 
# https://github.com/JuliaAudio/LibSndFile.jl

save(joinpath(homedir(), "Desktop", "myvoice.ogg"), buf)

# Reload it via
x = load(joinpath(homedir(), "Desktop", "myvoice.ogg"))

write(stream,x)

# Close the stream
close(stream)


