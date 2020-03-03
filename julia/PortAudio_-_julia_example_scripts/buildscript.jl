using Pkg
#Pkg.add(PackageSpec(url="https://github.com/JuliaAudio/PortAudio.jl#julia1")); #This doesn't work, hit "]" and add the url with "add https..."
#Pkg.add("RingBuffers#master"); #also doesn't work do the same as above
Pkg.build("RingBuffers");
Pkg.build("PortAudio")
#Pkg.add("SampledSignals#master") #Same as above, doesn't work
