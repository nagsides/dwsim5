function [f Z EoS] = fugF(EoS,T,P,mix,phase,varargin)
%Calculates the fugacity and compressibility coefficient of mixture mix at temperature T
%and pressure P using Peng-Robinson EoS
%
%Parameters:
%EoS: Equation of state used for calculations
%T: Temperature(K)
%P: Pressure (K)
%mix: cMixture object
%liquid: set phase = 'liq' to calculate the fugacity of a liquid phase or
%   phase = 'gas' to calculate the fugacity of a gas phase
%
%Results:
%f: fugacity coefficient
%Z: compressibility coefficient 
%EoS: returns EoS used for calculations
%
%Reference: Walas, Phase Equilibria in Chemical Engineering,
%Butterword-Heineman, Newton MA (1985)

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

%************************************************
%Calculates the compressibility coefficient
%************************************************
R = 8.31; %Ideal gas constant, J/mol K

%Reads pure component properties and interaction coefficients
numC = mix.numC;
comp = mix.comp;
x = mix.x;
Tc = zeros(numC,1);
Pc = zeros(numC,1);
w = zeros(numC,1);
for i = 1:numC
    Tc(i) = comp(i).Tc;
    Pc(i) = comp(i).Pc;
    w(i) = comp(i).w;
end
k1 = mix.k1;
k2 = mix.k2;

%Reduced variables
Tr = zeros(numC,1);
Pr = zeros(numC,1);
for i = 1:numC
   Tr(i) = T/Tc(i);
   Pr(i) = P/Pc(i);
end

%Pure component parameters
alpha = zeros(numC,1);
a = zeros(numC,1);
b = zeros(numC,1);
for i = 1:numC
   alpha(i) = alpha_function(EoS,mix.comp(i),T); %Evaluates the alpha function (may differ in modifications of PR-EoS)
   a(i) = 0.45724*(R*Tc(i))^2/Pc(i)*alpha(i); %Eq. 2, Table 1.13 of reference
   b(i) = 0.0778*R*Tc(i)/Pc(i); %Eq. 3, Table 1.13 of reference
end

%Mixing rules
aij = zeros(numC,numC);
bij = zeros(numC,numC);
for i = 1:numC
   for j = 1:numC
      aij(i,j) = (1-k1(i,j))*sqrt(a(i)*a(j)); %Eq. 22, Table 3.4 of reference
      bij(i,j) = (1-k2(i,j))*(b(i) + b(j))/2; %Eq. 23, Table 3.4 of reference
   end
end

%Mixture parameters
am = 0;
bm = 0;
for i = 1:numC
   for j = 1:numC
      am = am + x(i)*x(j)*aij(i,j);
      bm = bm + x(i)*x(j)*bij(i,j);
   end
end
A = am*P/(R*T)^2; %Eq. 24, Table 3.4 of reference
B = bm*P/(R*T); %Eq. 25. Table 3.4 of reference

%Compressibility coefficient calculation, resolution of cubic equation
Z = roots([1 -(1-B) (A-3*B^2-2*B) -(A*B-B^2-B^3)]); %Eq. 7, Table 1.13 of reference

%Removes complex and negative roots
ZR = [];
for i = 1:3
   if isreal(Z(i)) && Z(i) > 0
   	ZR = [ZR Z(i)];   
   end
end

%Selects the coefficient corresponding to liquid (smallest positive root) or gas
%(largest root) phases
if strcmp(phase,'liq') == 1
    Z = min(ZR);   
elseif strcmp(phase,'gas') == 1
    Z = max(ZR);
else
    error(['The value "' phase '" of "phase" parameter is incorrect']);
end

%************************************************
%Calculates the fugacity coefficient
%************************************************
f = zeros(numC,1);
for comp = 1:numC
    sumat = 0;
    for i = 1:numC
        sumat = sumat + x(i)*aij(i,comp);
    end
    f(comp) = exp(b(comp)/bm*(Z-1) - log(Z-B)-A/(2*sqrt(2)*B)*(2*sumat/am - b(comp)/bm)*log((Z+2.414*B)/(Z-0.414*B))); %Eq. 29, Table 3.4 of reference
end