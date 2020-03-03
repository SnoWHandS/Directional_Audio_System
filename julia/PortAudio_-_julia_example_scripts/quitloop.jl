# Script to test quitting a loop
# https://stackoverflow.com/questions/23593986/detecting-keystrokes-in-julia
# AJW modified for Julia 1.1
# replace "contains" with "occursin"
# This method uses a Channel to communicate between tasks
# For reason, "readavailable(stdin)" does not return without  <enter>. Is this a bug?
# This means that one may as well use readline().

function kbtest()
    # allow 'q <enter>' typed on the keyboard to break the loop
    quitChannel = Channel(10)
    @async while true
        kb_input = readline(stdin)   
        println("Read: ",kb_input)
        if occursin("q",lowercase(kb_input))
            put!(quitChannel, 1)
            break
        end
    end

    start_time = time()
    while (time() - start_time) < 10
        if isready(quitChannel)
            break
        end

        println("in loop @ $(time() - start_time)")
        sleep(1)
    end

    println("out of loop @ $(time() - start_time)")
end
