%This example shows the application of the Peng-Robinson equation of state
%with Stryjek-Vera alpha function for the thermodynamic modelling of 
%carbon dioxide + dichloromethane mixtures
%Reference for the parameters: �. Mart�n and M. J. Cocero, J. Supercrit.
%Fluids 32 (2004) 203-219

%For application of the cubic PR-EoS, the following pure component
%parameters are required: critical temperature, critical pressure,
%acentric factor and kappa parameter of the Stryjek-Vera alpha function
CO2 = cSubstance;
CO2.name = 'Carbon Dioxide';
CO2.Tc = 304.1; 
CO2.Pc = 7.38e6;
CO2.w = 0.225;
CO2.EoSParam = 0.04285; %kappa parameter of Stryjek-Vera

DCM = cSubstance;
DCM.name = 'Dichloromethane';
DCM.Tc = 510; 
DCM.Pc = 6.08e6;
DCM.w = 0.199;
DCM.EoSParam = 0.0746;

mix = cMixture;
mix.comp(1) = CO2;
mix.comp(2) = DCM;
mix.x = [0.5 0.5];

%PRSV-EoS uses conventional quadratic mixing rules, requiring two interaction
%parameters 'k1' and 'k2' for mixture parameters 'a' and 'b', respectively
%Both parameters can be temperature-dependant
mix.k1 = [0 0.0646;0.0646 0];
mix.k2 = [0 0.0886;0.0886 0];

EoS = cPRSVEoS; 

[beta, x, y, K, val, time, EoS] = Flash(EoS,1e6,313,mix,[0 1],[1 0],0.5)