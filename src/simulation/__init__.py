"""
Simulation Module

This module contains all simulation-related functionality:
- MATLAB Spinach backend (spinach_bridge)
- Pure Python quantum simulation backend
- Simulation UI components
- Simulation worker threads
"""

from .ui.simulation_window import MultiSystemSpinachUI

__all__ = ['MultiSystemSpinachUI']
