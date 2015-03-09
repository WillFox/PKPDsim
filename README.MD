# Description

A library to perform simulations from a PKPD model, defined using a system of ODEs, model parameter estimates, a dosing regimen, and optionally a between-subject variability matrix. The library also provides a model exploration tool that dynamically generates a Shiny app from the specified model and parameters.

## Rationale

In pharmacometrics, many models are defined as systems of ordinary differential equations (ODEs). Although solving ODEs numerically in R is relatively straightforward using the deSolve library, the implementation of e.g. infusions and complex dosing regimens as well as the simulation of patient populations with multi-level random effects is cumbersome. Therefore, many modelers currently resort to Berkeley Madonna (BM) to perform exploratory simulations instead of performing them in R. BM does provide some excellent interactivity features and is fast, but is: 

- inferior regarding plotting functionality
- cumbersome regarding implementation of dose regimens and multi-level variability 
- not open source/free. 

In essence, the `PKPDsim` tool is an attempt to take the best features of BM, and offer them whithin the R environment so that the modeler can take advantage of e.g. the plotting and visualization tools in R. The library aims to facilitate simulation of any dosing regimen for PKPD mixed-effects models and is implemented as a wrapper around the deSolve library. Inputs for the main function (`sim_ode`) include: a function describing the ODE system, an object describing the regimen, a list of fixed-effects, and a matrix describing the between patient variability. The `PKPDsim` library can dynamically generate Shiny frontends (see figure below) offering features similar to BM. 

![Shiny](images/shiny.png "Shiny example")

Recently, Inria (through the DDMoRe consortium) released a similar library for R (`mlxR`, https://github.com/MarcLavielle/mlxR). While the `mlxR` library offers some great features, the main differences are that `mlxR`:

- uses a proprietary and closed-source simulation engine (`simulx`)
- requires models specified in PharmML instead of R
- (currently) does not offer functionality to dynamically generate Shiny apps

## Future plans
- will be released to CRAN
- implement models as compiled C code

## Installation

```
library(devtools)
install_github("ronkeizer/PKPDsim")
library(PKPDsim)
```

## Example single subject

```
# Single subject simulation (population values)
p <- list(CL = 38.48, V  = 7.4,
          Q2 = 7.844, V2 = 5.19,
          Q3 = 9.324, V3 = 111)

r1 <- regimen(amt = 100,
              times = c(0, 24, 36),
              type = "infusion")

dat <- sim_ode (ode = pk_3cmt_iv,
                par = p,
                regimen = r1)

ggplot(dat, aes(x=t, y=y)) +
  geom_line() +
  scale_y_log10() +
  facet_wrap(~comp)
```

## Example custom ODE

```
pk_1cmt_iv <- function (t, A, p) {
  with(p, {
    KEL <-  CL/V
    dAdt_1 <- -KEL*A[1] + rate
    return ( list ( c (  dAdt_1 ) ) )
  })
}
attributes(pk_1cmt_iv) <- list(obs = list (cmt = 1, scale = "V"))
p <- list(CL = 38.48, V  = 7.4)

dat <- sim_ode (ode = pk_1cmt_iv,
                par = p,
                regimen = r1)

ggplot(dat, aes(x=t, y=y)) +
  geom_line() +
  scale_y_log10() +
  facet_wrap(~comp)
```


## Example between-subject variability
```
omega <- c(0.3,       # IIV CL
           0.1, 0.3)  # IIV V

dat <- sim_ode (ode = pk_3cmt_iv,
                par = p,
                omega = omega,
                n_ind = 20,
                regimen = r1)

ggplot(dat, aes(x=t, y=y, colour=factor(id), group=id)) +
  geom_line() +
  scale_y_log10() +
  facet_wrap(~comp)
```

## Example Shiny
```
library(PKPDsim)

p <- list(CL = 38.48,
          V  = 7.4,
          Q2 = 7.844,
          V2 = 5.19,
          Q3 = 9.324,
          V3 = 111)

omega <- c(0.3,       # IIV CL
           0.1, 0.3)  # IIV V

sim_ode_shiny(ode = pk_3cmt_iv,
              par = p,
              omega = omega)
```