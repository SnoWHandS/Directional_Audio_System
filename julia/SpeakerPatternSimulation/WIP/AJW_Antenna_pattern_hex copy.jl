# Script to calculate beam pattern from aperture distribution
# 2D FFT Method
# AJW & DH 2020-05-08
#
# To do: relate frequency domain to angle and label plot axes.
using FFTW

# Define a matrix of points to hold the aperture.
dx = 1.0
dy = dx
N=1024;   # Making N bigger implements zero-padding for finer other-domain spacing.
A=zeros(N,N);   # A holds the aperture distribution (e.g. Sound pressure level or E field strength)
x_axis = 0:dx:(N-1)*dx
y_axis = 0:dy:(N-1)*dy

function fill_circle(x0,y0,r0,fill_value,A)
# This function fills a circle, centres (x0,y0) of radius r with ones inside matrix A
# Array A is passed by reference
  (Ncols,Nrows)=size(A)
  i0=x0/dx
  j0=y0/dy
  iStart=i0-(r0/dx+1)
  iEnd=i0+(r0/dx+1)
  jStart=j0-(r0/dy+1)
  jEnd=j0+(r0/dy+1)

  for i=iStart:iEnd 
    for j=jStart:jEnd
      x = i*dx
      y = j*dy
      R = sqrt( (x-x0)^2 + (y-y0)^2 )
      if R<=r0
        A[i,j]=fill_value
      end
    end
  end

end


function createArray(x1,y1,r1)
  (Ncols,Nrows)=size(A)
  for i=1:Ncols; 
       for j=1:Nrows
         x = i*dx
         y = j*dy
         R = sqrt( (x-x1)^2 + (y-y1)^2 )
         if R<=r0
           fill_circle(x0,y0,r0,fill_value,A)
         end
       end
  end
end
#define dimensions of the square grid
dimx=7  #2x2 = 18 3x3 = 9  9x9 = 18/8
dimy=7
offset=1.25 #accounts for the external radius of the transducer
# Fill Aperture matrix with one circular object
ApetureDia = 13.7
r0= ApetureDia/2   #interior radius = 13.7/2 = 6.85mm
x0=N/4;  
y0=N/4;
fill_value=1;
transducerDia = 16.2

elementSpacing = transducerDia
wavelength=(343/40000)*1000;  #in mm
First_grating_lobe_angle_deg = asin(wavelength/elementSpacing)/pi*180  # d sin(theta) = lambda -> around 30.3
#Second_grating_lobe_angle_deg = asin(2*wavelength/elementSpacing)/pi*180  # d sin(theta) = lambda
println("First_grating_lobe_angle_deg = $(First_grating_lobe_angle_deg), deg")
#println("Second_grating_lobe_angle_deg = $(Second_grating_lobe_angle_deg), deg")

xmid = x0 + (dimx-1)*sqrt(3)*elementSpacing/2
ymid = y0 + (dimy-1)*elementSpacing/2
#array_radius = (xmid-x0) + elementSpacing/2
array_radius = 41
for i=0:dimx-1
  for j=0:dimy-1
      x1 = x0+(i*sqrt(3)*elementSpacing)
      y1 = y0+(j*elementSpacing)
      radial_distance = sqrt((x1-xmid)^2+(y1-ymid)^2)
      if radial_distance <= array_radius 
         fill_circle(x1,y1,r0,fill_value,A)
      end

      x1 = x1 + sqrt(3)*elementSpacing/2
      y1 = y1 + elementSpacing/2
      radial_distance = sqrt((x1-xmid)^2+(y1-ymid)^2)
      if radial_distance <= array_radius 
         fill_circle(x1,y1,r0,fill_value,A)
      end
    end
  end


fill_circle(xmid,ymid,r0/2,2,A)

B = fftshift(abs.(fft(A)))   # beam pattern
#close("all")
# PyPlot commands (One can also use Plots with plotly backend)
if(false)
using PyPlot
figure(1)
mycolormap = "jet"  # "hsv" "grey" etc. "jet", "
imshow(A); colorbar()
figure(2)
imshow(B, cmap=mycolormap); colorbar()
figure(3)
surf(A, cmap=mycolormap)
figure(4)
surf(B, cmap=mycolormap)
figure(5)
surf(20*log10.(B .+ maximum(B)/10000), cmap=mycolormap)
end

# Plots commands for plotly() backend - uses OpenGL graphics
if(true)
using Plots  # takes 60s to first plot, but worth the wait!

#plotly()    # Plot appears in browser window
#gr()
pyplot()

heatmap(A, size = (1440, 900),reuse=false)
gui()

#=
heatmap(B,size = (1440, 900), reuse=false)
gui()
surface(A, size = (1440, 900),reuse=false)
gui()
=#
#surface(B, size = (1440, 900), reuse=false)
#gui()
#=
surface(20*log10.(B .+ maximum(B)/10000), color=cgrad([:red,:blue]), reuse=false)
gui()=#
end

