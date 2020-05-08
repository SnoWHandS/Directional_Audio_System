using PyPlot
using FFTW		#for 2d fft to describe beam pattern of this aperture

#Creates a circular transducer at specified coordinates
function fill_tx(x0,y0,r0,A)
    (dx,dy)=(1,1)
	for i=1:N
		for j=1:N
			x = i*dx
			y = j*dy
			R = sqrt( (x-x0)^2 + (y-y0)^2 )
			if R<=r0
				A[i,j]=1
			else
				A[i,j]=0
			end
		end
	end
end




#make function for populating squares with circles
(x0,y0) = (100,100)		#position
r0 = 50					#radius of transducer
N=512
A=zeros(N,N);			#define whole grid - Aperture distribution (E Field strength)
fill_tx(x0,y0,r0,A)

surf(A)					#plot the surface

X = fft(A);	            #creates a 2d fft (with complex values included)
figure()
surf(fftshift(abs.(X)))	#shift to center and plot 2d fft

