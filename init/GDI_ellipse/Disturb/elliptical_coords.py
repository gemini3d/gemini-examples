#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 21 19:59:54 2025

Utilities for calculations involving elliptical coordinates.  Reference ellipse
is defined as:
    
    x**2/a**2 + y**2/b**2 = 1
    
    where a and b are semi-major(minor) axes and c**2 = b**2 - a**2 is the
    elliptical eccentricity.  

Equivalently this can be written:

    x**2 + y**2/d**2 = a**2
    
    where d**2=b**2/a**2 (for b>a) is the ratio of semi-major to semi-minor axes
    
Formulas taken from:  Che Sun. Explicit Equations to Transform from Cartesian to Elliptic Coordinates. Mathematical Modelling and Applications.
Vol. 2, No. 4, 2017, pp. 43-46. doi: 10.11648/j.mma.20170204.12

Verified through numerical testing only.  Notation used is based on Wikipedia:
    https://en.wikipedia.org/wiki/Elliptic_coordinate_system

@author: zettergm
"""

import numpy as np
from numpy import cosh,cos,sinh,sin,sqrt,arcsin,pi,log

# Convert elliptical coordinates mu,nu (parameters a,b) to Cartesian x,y
def elliptical2cart(mu,nu,a,b):       
    c=sqrt(b**2-a**2)
    x=c*cosh(mu)*cos(nu)
    y=c*sinh(mu)*sin(nu)      # sinh goes with minor axis?
    return x,y


# Convert Cartesian x,y coordinate to elliptical mu,nu (parameters a,b)
def cart2elliptical(X,Y,a,b):
    c=sqrt(b**2-a**2)

    x=X.reshape(X.size,order='F')    
    y=Y.reshape(Y.size,order='F')
    
    B=x**2+y**2-c**2
    
    p=(-B+sqrt(B**2+4*c**2*y**2))/2/c**2    # discriminant last term should be minor axis?
    q=(-B-sqrt(B**2+4*c**2*y**2))/2/c**2
    
    p[p>1.0]=1.0      # handles issues with precision
    
    mu=1/2*log(1-2*q+2*sqrt(q**2-q))
    nu0=arcsin(sqrt(p))
    
    nu=np.empty(nu0.shape)
    for i in range(0,nu0.size):     # need to swap x,y if axis swapped?
        if (x[i]>=0 and y[i]>=0):
            nu[i]=nu0[i]
        elif (x[i]<0 and y[i]>=0):
            nu[i]=pi-nu0[i]
        elif (x[i]<=0 and y[i]<0):
            nu[i]=pi+nu0[i]
        else:
            nu[i]=2*pi-nu0[i]
                
    MU=mu.reshape(X.shape,order='F')
    NU=nu.reshape(X.shape,order='F')
    
    return MU,NU


# Compute metric factors at a given location
def elliptical_metric(mu,nu,a,b):
    c=sqrt(b**2-a**2)
    hmu=c*sqrt(sinh(mu)**2+sin(nu)**2)
    hnu=hmu
    return hmu,hnu    


# Metric factor derivatives d/dmu(hmu) used in various calculations
def elliptical_metric_derivative(mu,nu,a,b):
    c=sqrt(b**2-a**2)
    dhmudmu = c * (sinh(mu)*cosh(mu)) /sqrt( sinh(mu)**2 + sin(nu)**2 )    
    return dhmudmu


# Integrated metric factor using first-order expansion of metric analytically integrated
def elliptical_metric_integral(mu,nu,a,b,mu0):
    """
    In order the arguments are:
        - mu point at which primitive is evaluated
        - nu point at which primitive eval.
        - semiminor axis
        - semimajor axis
        - reference point for Taylor expansion of hmu
    """
    hmu0,_ = elliptical_metric(mu0,nu,a,b)
    dhmudmu0 = elliptical_metric_derivative(mu0,nu,a,b)
    Hmu = mu*(hmu0-dhmudmu0*mu0) + mu**2 * (1/2) * dhmudmu0
    return Hmu
    
    
