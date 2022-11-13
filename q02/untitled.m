clc;
clear all;

vl = 13800; %Line Voltage
S = 50000000; % potência aparente do GS
Xs = 2.5; % reatância síncrona do GS
Ra = 0; % resistência de armadura do GS
fp = 0.9; % fator de potência (atrasado)
fp_estado = 'i'; % i - indutivo e c-capacitivo
ligacao = 'd'; % y - ligacao Y e d - ligacao delta
num_polos = 4; % Número de polos da máquina.
freq_ele = 60; % frequência elétrica em Hz.
Vp = vl/sqrt(3);

%Ia and Ia Phase
Ia = S/(sqrt(3)*vl*fp);
Ia = Ia/sqrt(3);
Ia_phase = acos(-1*fp);
%Converting Ia to rectangular form
Ia_complex = Ia * exp(Ia_phase*1i);
%Calculating Ea in the rectangular form
Ea_complex = vl - Ia_complex*Xs*1i;
%Converting Ea to polar form
Ea_mod = abs(Ea_complex);
Ea_phase = angle(Ea_complex);


Pout = S*0.6*fp;
% Considering the lossless system
%Pin = Pout - 1*10^6 - 1,5*10^6
Pin = Pout;

for c = 1:4
    
    Ea_newphase = asin((Pin*Xs)/(3*vl*Ea_mod));
    Ea_newcomplex = Ea_mod*exp(Ea_newphase*1i);
    Ia_newcomplex = (vl-Ea_newcomplex)/(Xs*1i);
    Ia_newmod = abs(Ia_newcomplex);
    Ia_newphase = angle(Ia_newcomplex);
    Pout = Pout + (S*0.1*fp);

    quiver(0*abs(Ea_newcomplex),0*imag(Ea_newcomplex),abs(Ea_newcomplex),imag(Ea_newcomplex),0,'g');
    hold on;
    quiver(0*Vp,0*Vp,Vp,0*Vp,0,'b');
    quiver(0*Vp,0*Vp,Ia_newmod*cosd(Ia_newphase),Ia_newmod*sind(Ia_newphase),0,'r');
    %quiver(Vp,0*Vp,abs(jXsIa),abs(jXsIa),0,'m');
    pause; %('on');
end