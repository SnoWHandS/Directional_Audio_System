using PortAudio, GR

#PortAudioStream("HDA Intel PCH: ALC3246 Analog (hw:0,0)", "SB Live! 24-bit External: USB Audio (hw:1,0)") do stream
PortAudioStream(1,1; synced=true) do stream
    #buf = read(stream)
    #buf = real((buf.+0im).^(1/2))
    #plot(buf)
    write(stream, stream)
end