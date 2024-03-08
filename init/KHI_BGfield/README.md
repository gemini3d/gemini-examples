# KHI_BGfield example

This example simulates ionospheric Kelvin-Helmholtz instability; with excitation through the background field inputs (unlike other KHI examples).  An advantage of this approach is that it allows one to have an zero-order equilibrium state that includes a field-aligned current to balance the system (as opposed to the usual formulation where a neutral wind balances the zero-order currents.  

## Zero-order equilibrium

For this type of simulation one needs to define how much out-of-balance the electric-field related perpendicular currents are in the initial state and enforce that throughout the simulation by omitting this imbalance from the source terms.  Otherwise the charge accumulation from the (apparent) imbalance will create a response field to drive the simulation back to a div(Jperp) = 0 state.  In the classic papers on ionospheric KHI the balancing current is provided by a neutral wind dynamo; however, any process that removes charge from the region where it otherwise would tend to accumulate due to the fields perpendicular will suffice; I.e. a presumed field-aligned current could provide the balance.  

## Specifying balance in the zero-order state

There are subtleties to specifying a background electric field -- even if it has been tuned in the initial conditions to balance the zero-order current density.  Scaled initial conditions, as needed to create density profiles, which are different on either side of the boundary layer, will shift around in altitude and also recombine at different rates (due to different drifts/heating), resulting in a response potential with large-scale variations that will tend to drive toward a numerical equilbrium.  Further as the simulation progresses E-region density tends to accumulate near the boundary which will have a tendency to short out the instability.  

## Perturbations in state variables

The balance term term (whether wind-driven for FAC in nature) cannot solely be calculated on the basis of the zero-order electric field since the perpendicular current from this will contain fluctuations from the density structures that should factor into the perturbed potential.  The result will be lack of instability and the perturbed potential will remain zero (if so initialized).  Alternatively, one could seed the initial potential with noise but the perturbations will simply decay at the inertial relaxation time; however, a response field seems to form in this case which mimics that present simulations where the balance terms are not omitted.  Hence, it appears necessary to define the balance state in the model input so that can be consistently subtracted, without perturbations, during the simulation.  

Using existing, FAC-mode inputs it should be possible to specify a FAC that balances the initial state *without perturbations* which will allow said perturbations to grow.  It must simply be the case that this FAC correspond exactly to the zero-order source term for the potential equation and that it remain constant in time through the simulation.  



