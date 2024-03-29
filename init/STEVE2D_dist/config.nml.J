&base
ymd = 2008,3,26               ! year, month, day
UTsec0 = 12600.0              ! start time in UT seconds
tdur = 600.0                  ! duration of simulation in seconds
dtout = 60.0                  ! how often to do output
activ = 150.0,150.0,50.0      ! f107a,f107,Ap
tcfl = 0.9                    ! target cfl number
Teinf = 1500.0                ! exospheric electron temperature
/

&setup
glat = 65
glon = 213
xdist = 1500e3             ! eastward distance (meters)
ydist = 200e3             ! northward distance (meters)
lxp = 1
lyp = 128
Bincl = 90
nmf = 5e11
nme = 2e11
alt_min = 80e3
alt_max = 950e3
!alt_scale = 50e3, 45e3, 400e3, 150e3
alt_scale = 10e3, 8e3, 500e3, 150e3  ! altitude grid scales (meters)
eq_dir = "~/simulations/STEVE2D_eq"
Efield_latwidth = 0.025
Jtarg = 6.5e-6
Jtarg_function = "fac_said"
/

&flags
potsolve = 1      ! solve electrodynamics:   0 - no; 1 - electrostatic; 2 - inductive
flagoutput = 1
/

&files
indat_size = 'inputs/simsize.h5'
indat_grid = 'inputs/simgrid.h5'
indat_file = 'inputs/initial_conditions.h5'
/

&efield
dtE0 = 60.
E0_dir = 'inputs/Efield/'
/

&precip_BG
PhiWBG=5e-2                   ! total energy flux (mW/m^2)
W0BG=1e3                      ! characteristic energy (eV)
/
