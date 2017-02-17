function Z = compr(EoS,T,P,mix,phase,varargin)
%Calculates the compressibility coefficient of mixture mix at temperature T
%and pressure P using GG EoS
%
%Parameters:
%EoS: Equation of state used for calculations
%T: Temperature(K)
%P: Pressure (Pa)
%mix: cMixture object
%phase: set phase = 'liq' to get the coefficient of the liquid phase, phase = 'gas' 
%   to get the coefficient of the gas phase 
%
%Optional parameters (set [] to keep default value)
%Z_ini: Initial guess for the compressibility coefficient
%   If not defined, the program uses an initial guess Z_ini = 0.8 for gas
%   phase and a Z_ini corresponding to a liquid density of 800 kg/m3 for
%   the liquid phase
%options: parameters of the fsolve numerical resolution method (structure
%   generated with "optimset")
%
%Results:
%Z: compresibility coefficient
%EoS: returns EoS used for calculations

%Copyright (c) 2011 �ngel Mart�n, University of Valladolid (Spain)
%This program is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%You should have received a copy of the GNU General Public License
%along with this program.  If not, see <http://www.gnu.org/licenses/>.

%Since the code is shared and to avoid duplication, this program uses the 
%function 'fug' to calculate the compressibility coefficent

[f Z] = fugF(EoS,T,P,mix,phase,varargin{:});