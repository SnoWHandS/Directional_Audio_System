import numpy as np
import sympy as sp
import matplotlib.pyplot as plt
from IPython.display import display
sp.init_printing()

#symbolic expression
t, v = sp.symbols('t v');


dt = 0.0000125  # time step  (to get Greek sybmol, type \Delta <tab>)
#t = 0:dt:0.002;  #Define time from 0 to 0.001s in steps of 0.0000125s
t=np.linspace(0,0.002,1/dt)
f0 = 1000  # 1000 Hz signal to be modulated
w0 = 2*sp.pi*f0;   # rad/s   ( Greek symbol \omega <tab>  )
A = 2    #4v p-p

v = A*sp.cos(w0*t);   # Create an array holding the sinusoid values

#x=np.linspace(-1,1,250)
#xSq=x**2
#y=(x**2)*np.sin(1/x**2)+x

#display(y)


plt.plot(t,v)
plt.xlabel('t')
plt.ylabel('v')
plt.show()