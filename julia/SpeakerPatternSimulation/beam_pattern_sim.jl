using PyPlot
using FFTW		#for 2d fft to describe beam pattern of this aperture

#Creates a circular transducer at specified coordinates
function fill_tx(x0,y0,r0)
    (dx,dy)=(1,1)
	for i=1:N
		for j=1:N
			x = i*dx
			y = j*dy
			R = sqrt( (x-x0)^2 + (y-y0)^2 )
			if R<=r0
				A[i,j]=1
			else
				#A[i,j]=0
			end
		end
	end
end




#make function for populating squares with circles
r0 = 50					#radius of transducer
N=1024                  #increase this for more zero padding
(x0,y0) = (N/4,N/4)		#position
global A=zeros(N,N);			#define whole grid - Aperture distribution (E Field strength)

#define dimensions of the square grid
dimx=5
dimy=5
offset=0
#fill in the square grid
for i=1:dimx
    for j=1:dimy
        fill_tx(x0+(i*2*r0+offset),y0+(j*2*r0+offset),r0)
    end
end

clf()
figure(1)
surf(A)					#plot the surface

X = fft(A);	            #creates a 2d fft (with complex values included)
figure(2)
surf(fftshift(abs.(X)))	#shift to center and plot 2d fft
# get the current axis argument of the plot
ax = gca()

# add new limits from 0 - n*9
ax.set_zlim([0,9000])