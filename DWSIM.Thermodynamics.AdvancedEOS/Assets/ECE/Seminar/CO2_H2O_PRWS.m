%Components
CO2 = cSubstance;
CO2.name = 'Carbon Dioxide';
CO2.MW = 44.01;
CO2.Tc = 304.2;
CO2.Pc = 7.38e6;
CO2.w = 0.225;

H2O = cSubstance;
H2O.name = 'Water';
H2O.MW = 18.015;
H2O.Tc = 647.3;
H2O.Pc = 22.048e6;
H2O.w = 0.3442;

%Mixture
mix = cMixture;
mix.comp(1) = CO2;
mix.comp(2) = H2O;

%Interaction coefficients
mix.k1 = [0 0.3073;0.3073 0];
mix.k2 = [0 0.1141;0.1141 0];
mix.k3 = [0 4.3870;0.3930 0];

%Equation of state
EoS = cPRWSEoS;

%P-xy diagram
[P,x,y] = PxyDiagram(EoS,mix,323,3.5e6,[1 0],20,[0.01 0.022],1);

%Enlarged diagrams with experimental data (Bamberger et al, J. Supercrit.
%Fluids 17 (2000) 97-110)
data = [4.05 0.0109 0.0046
    5.06 0.0137 0.0036
    6.06 0.0161 0.0037
    7.08 0.0176 0.0034
    8.08 0.019 0.0034
    9.09 0.02 0.0041
    10.09 0.0205 0.0045
    11.1 0.021 0.005
    12.1 0.0214 0.0055
    14.11 0.0217 0.0061];

figure();
plot(x(:,1),P,'-b');
hold on;
plot(data(:,2),data(:,1)*1e6,'ob');
xlabel ('xCO_2');
ylabel ('P (Pa)');
legend ('model','experimental');

figure();
plot(y(:,2),P,'-b');
hold on;
plot(data(:,3),data(:,1)*1e6,'ob');
xlabel ('yH_2O');
ylabel ('P (Pa)');
legend ('model','experimental');