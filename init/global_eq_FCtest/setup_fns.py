# This is mostly a repeat of model.setup from the pygemini repository except for that it setups up a periodic
#   grid for us in full-globe simulations.
from __future__ import annotations
import argparse
from pathlib import Path
import typing as T
import shutil
import os

from gemini3d.config import read_nml
import gemini3d.model


def model_setup(path: Path | dict[str, T.Any], out_dir: Path, gemini_root: Path = None):
    """
    top-level function to create a new simulation FROM A FILE config.nml

    Parameters
    ----------

    path: pathlib.Path
        path (directory or full path) to config.nml
    out_dir: pathlib.Path
        directory to write simulation artifacts to
    """

    # %% read config.nml
    if isinstance(path, dict):
        cfg = path
    elif isinstance(path, (str, Path)):
        cfg = read_nml(path)
    else:
        raise TypeError("expected Path to config.nml or dict with parameters")

    if not cfg:
        raise FileNotFoundError(f"no configuration found for {out_dir}")

    cfg["dphi"] = 90.0
    cfg["out_dir"] = Path(out_dir).expanduser().resolve()

    if gemini_root:
        cfg["gemini_root"] = Path(gemini_root).expanduser().resolve(strict=True)

    for k in {"indat_size", "indat_grid", "indat_file"}:
        cfg[k] = cfg["out_dir"] / cfg[k]

    # FIXME: should use is_absolute() ?
    for k in {"eq_dir", "eq_archive", "E0dir", "precdir"}:
        if cfg.get(k):
            cfg[k] = (cfg["out_dir"] / cfg[k]).resolve()

    # %% copy input config.nml to output dir
    input_dir = cfg["out_dir"] / "inputs"
    input_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(cfg["nml"], input_dir)

    os.environ["GEMINI_ROOT"] = "~/libs/bin/"

    # %% is this equilibrium or interpolated simulation
    if "eq_dir" in cfg:
        gemini3d.model.interp(cfg)
    else:
        gemini3d.model.equilibrium(cfg)
