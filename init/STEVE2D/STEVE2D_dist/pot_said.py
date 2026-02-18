#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  8 18:04:22 2022

@author: zettergm
"""
from __future__ import annotations
import logging
import typing as T

import xarray
import numpy as np
from scipy.special import erf


def pot_said(
    E: xarray.Dataset,
    xg: dict[str, T.Any],
    lx1: int,
    lx2: int,
    lx3: int,
    gridflag: int,
    flagdip: bool,
) -> xarray.Dataset:
    """
    synthesize a feature
    """

    if E.Etarg > 1:
        logging.warning(f"Etarg units V/m -- is {E['Etarg']} V/m realistic?")

    # NOTE: h2, h3 have ghost cells, so we use lx1 instead of -1 to index
    # pk is a scalar.
    # north-south
    S = E.Etarg * E.sigx3 * xg["h3"][lx1, 0, lx3 // 2] * np.sqrt(np.pi) / 2
    mlatmean = np.mean(E.mlat)

    taper = erf((E.mlat - mlatmean - E.mlatoffset) / E.mlatsig).data[None, :]
    taper = taper - erf((E.mlat - mlatmean) / E.mlatoffset).data[None, :] + 1
    taper = taper + erf((E.mlat - mlatmean + E.mlatoffset) / E.mlatsig).data[None, :]
    taper = -1 * taper

    assert S.ndim == 0, "S is a scalar"

    for t in E.time:
        E["flagdirich"].loc[t] = 1

        if gridflag == 1:
            E["Vminx1it"].loc[t] = S * taper
        else:
            E["Vmaxx1it"].loc[t] = S * taper

    return E
