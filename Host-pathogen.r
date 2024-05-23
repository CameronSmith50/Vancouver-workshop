# Code to run the host-pathogen system from workshop 2.
# This code will use the deSolve package to solve the host-pathogen ODE system,
# and ggplot2 to plot the resultant solution.
#
# Author: Cameron Smith
# Date created: 13/05/24

# Load any necessary librarys
library(deSolve)
library(ggplot2)
library(reshape2)

# Firstly, we need to define the RHS function of the ODEs.
# The inputs are:
#     > time t, which is required for the solver
#     > state variable, a named list. For the host-pathogen system (2.2) from
#       the notes, this is a list such as state = c(S = 100, I = 1)
#     > parameters list, which again should be named and have all parameters in
#       it. For example parameters = c(b = 0.1, K = 200, d = 0.01, beta = 0.05,
#       gamma = 0.1, alpha = 0.2)
hostPathogenFunc <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {

    # Sum the states to get total population
    N <- S + I

    # The susceptible equation
    dSdt <- b*N*(1 - N/K) - (d + transmission*I)*S + gam*I

    # The infceted equation
    dIdt <- transmission*S*I - (d + gam + alpha)*I

    # Output a list. This part is important
    list(c(dSdt, dIdt))
  })
}

# Define a list of times. Please be aware of this. Too many points and the code
# may take a while to run, too few and you may cause the code to break (called
# instability of the numerical method). This is just an experimentation as to
# what works
times <- seq(0, 100, by = 0.0001)  # c(0, 0.01, 0.02, ..., 99.9, 100) #nolint

# Now we solve the ODE. We will use the function ode from deSolve, which will
# create a list containing the times and the solutions at this time. To do
# this. Initialise an initial state and parameters list
state0 <- c(S = 100, I = 1)
parameters <- c(b = 0.1, K = 200, d = 0.01, transmission = 0.05, 
                gam = 0.1, alpha = 0.5)
out <- data.frame(ode(y = state0, times = times, func = hostPathogenFunc,
                      parms = parameters))
head(out)

# Plotting. Using ggplot to plot S and I on the same window
# This first line generates a new dataframe from out, where the time remains
# (id.vars) and then the others are converted to two columns, with the first
# being the column name from out, and the second being its value.
df <- melt(out,  id.vars = 'time', variable.name = 'state')
head(df)
plotPP <- ggplot(df, aes(time, value)) + geom_line(aes(colour = state))
plot(plotPP)
ggsave('host-pathogen.png', device='png')

# Create a function which can output the steady states
steadyStates <- function(parameters){
  with(as.list(c(parameters)), {
    print('Steady states are:')

    # Extinction steady state
    df = data.frame(type = 'Extinction', S = 0, I = 0)

    # Disease-free steady state
    df[2,] = c('Disease-free', S = K*(b-d)/b, I=0)

    # Extinction steady state
    S = (d + gam + alpha)/transmission
    I = -(K/(2*b))*(d+alpha+2*b*S/K-b) + c(0.5, -0.5)*sqrt(((K/b)*(d+alpha+2*b*S/K-b))^2 + (4*K/b)*S*(b*(1-S/K)-d))

    df[3,] = c('Endemic', S, I[1])
    df[4,] = c('Endemic', S, I[2])
    print(df)
  })
}

steadyStates(parameters)


# Discrete time systems

birth <- 20
death <- 0.2

# Model N(n+1) = b - dN(n)

# Initial condition
N0 <- 10

# Population list
pop <- c(N0)

for (n in 1:1000){
  N1 <- birth - death*N0

  # Append to list
  pop <- c(pop, N1)

  N0 <- N1
}

head(pop)
plot(pop)
