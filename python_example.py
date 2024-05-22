import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

def RHSfunction(state, t, pars):
    # State variable:
    #   - S = state[0]
    #   - I = state[1]
    # Parameters
    #   - b = pars[0]
    #   - K = pars[1]
    #   - d = pars[2]
    #   - beta = pars[3]
    #   - gamma = pars[4]
    #   - alpha = pars[5]

    # Set the total population as the sum of the states
    N = np.sum(state)

    # Susceptible equation
    dSdt = pars[0]*N*(1 - N/pars[1]) - (pars[2] + pars[3]*state[1])*state[0] + \
            pars[4]*state[1]
    
    # Infected equation
    dIdt = pars[3]*state[0]*state[1] - (pars[2] + pars[4] + pars[5])*state[1]

    # Return
    return(np.array([dSdt, dIdt]))

# Define the state variables, parameters and times
state0 = np.array([100, 1])
pars = np.array([0.1, 200, 0.01, 0.05, 0.1, 0.5])
times = np.linspace(0, 100, 10001)

# Solve the ODE and extract the solution
out = odeint(RHSfunction, state0, times, args = (pars,))

# Plot
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(times, out[:,0], 'r', lw=2, label='S')
ax.plot(times, out[:,1], 'b', lw=2, label='I')
ax.legend()
plt.show()