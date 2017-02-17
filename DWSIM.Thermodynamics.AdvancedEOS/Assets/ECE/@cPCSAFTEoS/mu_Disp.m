function [muDisp EoS] = mu_Disp(EoS,T,dens_num,mix)
%Calculates the dispersion contribution to the residual chemical potential 
%of mixture mix at temperature T and pressure P using PC-SAFT EoS
%
%Parameters:
%EoS: Equation of state used for calculations
%T: Temperature(K)
%P: Pressure (K)
%dens_num: Number density (molecule/Angstrom^3)
%mix: cMixture object
%
%Results:
%muass: residual chemical potential, association contribution
%EoS: returns EoS used for calculations
%
%Reference: Gross and Sadowski, Ind. Eng. Chem. Res. 40 (2001) 1244-1260

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

%Equation constants
a0(1) = 0.9105631445;
a0(2) = 0.6361281449;
a0(3) = 2.6861347891;
a0(4) = -26.547362491;
a0(5) = 97.759208784;
a0(6) = -159.59154087;
a0(7) = 91.297774084;
a1(1) = -0.3084016918;
a1(2) = 0.1860531159;
a1(3) = -2.5030047259;
a1(4) = 21.419793629;
a1(5) = -65.255885330;
a1(6) = 83.318680481;
a1(7) = -33.746922930;
a2(1) = -0.0906148351;
a2(2) = 0.4527842806;
a2(3) = 0.5962700728;
a2(4) = -1.7241829131;
a2(5) = -4.1302112531;
a2(6) = 13.776631870;
a2(7) = -8.6728470368;
b0(1) = 0.7240946941;
b0(2) = 2.2382791861;
b0(3) = -4.0025849485;
b0(4) = -21.003576815;
b0(5) = 26.855641363;
b0(6) = 206.55133841;
b0(7) = -355.60235612;
b1(1) = -0.5755498075;
b1(2) = 0.6995095521;
b1(3) = 3.8925673390;
b1(4) = -17.215471648;
b1(5) = 192.67226447;
b1(6) = -161.82646165;
b1(7) = -165.20769346;
b2(1) = 0.0976883116;
b2(2) = -0.2557574982;
b2(3) = -9.1558561530;
b2(4) = 20.642075974;
b2(5) = -38.804430052;
b2(6) = 93.626774077;
b2(7) = -29.666905585;

%Reads pure-component properties
m = zeros(1,mix.numC);
sigma = zeros(1,mix.numC);
epsilon = zeros(1,mix.numC);
for i = 1:mix.numC
    m(i)= mix.comp(i).EoSParam(1);
    sigma(i) = mix.comp(i).EoSParam(2);
    epsilon(i) = mix.comp(i).EoSParam(3);
end

%Calculates the temperature-dependant segment diameter
d = zeros(1,mix.numC);
for i = 1:mix.numC
    d(i) = HardSphereDiameter(EoS,T,m(i),sigma(i),epsilon(i));
end

%mean segment number
m_prom = 0;
for i = 1:mix.numC
    m_prom = m_prom + m(i)*mix.x(i); %Eq. 6 of reference
end

%Calculates the a and b parameters
a = zeros(1,7);
b = zeros(1,7);
for j = 1:7
    a(j) = a0(j)+(m_prom-1)/m_prom*a1(j)+(m_prom-1)/m_prom*(m_prom-2)/m_prom*a2(j); %Eq. 18 of reference
    b(j) = b0(j)+(m_prom-1)/m_prom*b1(j)+(m_prom-1)/m_prom*(m_prom-2)/m_prom*b2(j); %Eq. 19 of reference
end

%Reduced density
dens_red = 0;
for i = 1:mix.numC
    dens_red = dens_red + mix.x(i)*m(i)*d(i)^3;
end
dens_red = dens_red*pi/6*dens_num; %Eq. 9 of reference

%Mixing rules
sigmaij = zeros(mix.numC, mix.numC);
epsilonij = zeros(mix.numC, mix.numC);
for i =1:mix.numC
    for j = 1:mix.numC
        sigmaij(i,j) = 0.5*(sigma(i) + sigma(j)); %Eq. A14 of reference
        epsilonij(i,j) = sqrt(epsilon(i)*epsilon(j)) * (1 - mix.k1(i,j)); %Eq A15 of reference           
    end
end

%Compressibility coefficient
Zdisp = Z_disp(EoS,T,dens_num,mix);

%Helmholtz energy
[Adisp] = HelmholtzDisp(EoS,T,dens_num,mix);

%Dispersion contribution
dauxil_dxk= zeros(4,mix.numC);
for j = 1:4
    for i = 1:mix.numC
        dauxil_dxk(j,i)=pi/6*dens_num*m(i)*d(i)^(j-1); %Eq. A34 of reference
    end
end

prom1 = 0;
prom2 = 0;
for i = 1:mix.numC
    for j = 1:mix.numC
        prom1 = prom1 + mix.x(i)*mix.x(j)*m(i)*m(j)*epsilonij(i,j)/T*sigmaij(i,j)^3; %Eq. A12 of reference
        prom2 = prom2 + mix.x(i)*mix.x(j)*m(i)*m(j)*(epsilonij(i,j)/T)^2*sigmaij(i,j)^3; %Eq. A13 of reference
    end
end

der_prom1 = zeros(1,mix.numC);
der_prom2 = zeros(1,mix.numC);
for i = 1:mix.numC
    sum1 = 0;
    sum2 = 0;
    for j = 1:mix.numC
        sum1 = sum1 + mix.x(j)*m(j)*(epsilonij(i,j)/T)*sigmaij(i,j)^3;
        sum2 = sum2 + mix.x(j)*m(j)*(epsilonij(i,j)/T)^2*sigmaij(i,j)^3;
    end
    der_prom1(i) = 2*m(i)*sum1; %Eq. A39 of reference
    der_prom2(i) = 2*m(i)*sum2; %Eq. A40 of reference
end

I1 = 0;
I2 = 0;
for j = 1:7
    I1 = I1 + a(j)*dens_red^(j-1); %Eq. A16 of reference
    I2 = I2 + b(j)*dens_red^(j-1); %Eq. A17 of reference
end

term1 = (m_prom)*(8*dens_red-2*dens_red^2)/(1-dens_red)^4;
term2 = (1-m_prom)*(20*dens_red-27*dens_red^2+12*dens_red^3-2*dens_red^4)/((1-dens_red)*(2-dens_red))^2;
C1 = (1+term1 + term2)^-1; %Eq. A11 of reference

term1 = m_prom*(-4*dens_red^2+20*dens_red+8)/(1-dens_red)^5;
term2 = (1-m_prom)*(2*dens_red^3+12*dens_red^2-48*dens_red+40)/((1-dens_red)*(2-dens_red))^3;
C2 = -C1^2*(term1 + term2); %Eq. A31 of reference

der_C1 = zeros(1,mix.numC);
for i = 1:mix.numC
    term1 = m(i)*(8*dens_red - 2*dens_red^2)/(1-dens_red)^4;
    term2 = m(i)*(20*dens_red - 27*dens_red^2 + 12*dens_red^3 - 2*dens_red^4)/((1-dens_red)*(2-dens_red))^2;
    
    der_C1(i) = C2*dauxil_dxk(4,i) - C1^2*(term1 - term2); %Eq. A41 of reference
end

der_a = zeros(7,mix.numC);
der_b = zeros(7,mix.numC);
for i = 1:7
    for j = 1:mix.numC
        der_a(i,j) = m(j)/m_prom^2*a1(i) + m(j)/m_prom^2*(3-4/m_prom)*a2(i); %Eq. A44 of reference
        der_b(i,j) = m(j)/m_prom^2*b1(i) + m(j)/m_prom^2*(3-4/m_prom)*b2(i); %Eq. A45 of reference
    end
end

der_I1 = zeros(1,mix.numC);
der_I2 = zeros(1,mix.numC);
for i = 1:mix.numC
    sum1 = 0;
    sum2 = 0;
    for j = 1:7
        sum1 = sum1 + a(j)*(j-1)*dauxil_dxk(4,i)*dens_red^(j-2) + der_a(j,i)*dens_red^(j-1); %Eq. A42 of reference
        sum2 = sum2 + b(j)*(j-1)*dauxil_dxk(4,i)*dens_red^(j-2) + der_b(j,i)*dens_red^(j-1); %Eq. A43 of reference
    end
    der_I1(i) = sum1;
    der_I2(i) = sum2;
end

dadisp_dxk = zeros(1,mix.numC);
for i = 1:mix.numC
    term1 = -2*pi*dens_num*(der_I1(i)*prom1 + I1*der_prom1(i));
    term2 = -pi*dens_num*((m(i)*C1*I2 + m_prom*der_C1(i)*I2 + m_prom*C1*der_I2(i))*prom2 + m_prom*C1*I2*der_prom2(i));
    dadisp_dxk(i) = term1 + term2; %Eq. A38 of reference
end

%Chemical potential
sum1 = 0;
for i = 1:mix.numC
    sum1 = sum1 + mix.x(i)*dadisp_dxk(i);
end

muDisp = zeros(1,mix.numC);
for i = 1:mix.numC
    muDisp(i) = Adisp + Zdisp + dadisp_dxk(i) - sum1 ; %Eq. A33 of reference
end
