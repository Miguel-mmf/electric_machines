clc
clear
addpath 'E:\Repositories Github\electric_machines\utils'

%% Variáveis de Entrada
%vt = 13800; % tensão de terminal do GS
%vl = 13800; % tensão de linha do GS
S = 50000000; % potência aparente do GS
Xs = 2.5; % reatância síncrona do GS
Ra = 0;%0.2; % resistência de armadura do GS
fp = 0.9; % fator de potência (atrasado)
fp_estado = 'i'; % i - indutivo e c-capacitivo
ligacao = 'y'; % y - ligacao Y e d - ligacao delta
num_polos = 4; % Número de polos da máquina.
freq_ele = 60; % frequência elétrica em Hz.

% esse arquivo será importado no dashboard
If_x_Vt = readtable('./caracteristica_a_vazio_gs.csv');
s = size(If_x_Vt.VT);

figure;
plot(If_x_Vt.IF,If_x_Vt.VT,"Color","b",'LineWidth',2);
grid on;
xlabel('Corrente de Campo (A)','Interpreter','latex');
ylabel('Tensão de Terminal (V)','Interpreter','latex');
title('Caracteristica a Vazio do Gerador Síncrono','Interpreter','latex');

Eax_test = zeros(s(1)-8,1);
Eay_test = zeros(s(1)-8,1);

figure;
for c = 8:s(1)

    Vt = If_x_Vt(c,:).VT; % tensão de terminal com base na curva caracterísitca a vazio do GS

    %% Cálculo - GS operando Nominalmente
    [Ia_ref,Il_ref,Ea_ref,Z_ref,Fp_ref,Vel_rpm] = calc_op_nominal_gs( ...
        Vt, ...
        ligacao, ...
        S, ...
        num_polos, ...
        freq_ele, ...
        Xs, ...
        Ra);

    %% Tensão de Fase
    [Vp,Vl] = calc_tensao_fase(Vt,ligacao);

    %% Cálculo da Corrente de Armadura
    [Ia,Ia_phase,Il,Il_phase] = calc_correntes(S,Vl,fp,fp_estado,ligacao);

    %% Tensão Induzida Interna do GS
    [Ea,jXsIa,Z] = calc_tensao_induzida(Vp,0,Ia,Ia_phase,Xs,Ra); % angulo de fase de Vp é 0
    disp(abs(Ea))

    Eax_test(c-7) = abs(Ea);
    Eay_test(c-7) = imag(Ea);

    %% Cálculo de Ia, Il, Ea e Fp em pu
    % tá funcionando
%     [Ia_pu,Il_pu,Ea_pu,Z_pu,Fp_pu] = calc_gs_pu( ...
%         Ia_ref, ...
%         Il_ref, ...
%         Ea_ref, ...
%         Z_ref, ...
%         Fp_ref, ...
%         Ia, ...
%         Il, ...
%         Ea, ...
%         Z, ...
%         fp);

    %% Novo Fator de Potência
    fp = acos((Ea*sind(0-angle(Ea)))/(abs(Z)*Ia));
    
    %% Gráficos
    %compass(abs(Ea),imag(Ea),'-.','g');
    quiver(0*abs(Ea),0*imag(Ea),abs(Ea),imag(Ea),0,'g');
    hold on;
    quiver(0*Vp,0*Vp,Vp,0*Vp,0,'b');
    quiver(0*Vp,0*Vp,Ia*cosd(Ia_phase),Ia*sind(Ia_phase),0,'r');
    quiver(Vp,0*Vp,abs(jXsIa),abs(jXsIa),0,'m');
    %compass(Vp,0,'b');
    %compass(Ia*cosd(Ia_phase),Ia*sind(Ia_phase),'r');
    %compass(abs(jXsIa),imag(jXsIa),'m');
    %compass(Ea,'-.','r')

    %break
    pause

end

figure;
compass(abs(Eax_test),imag(Eay_test));
fig2plotly('TreatAs', 'compass');

% figure;
% disp(zeros(s(1)-7,1));
% disp(Eax_test);
% disp(Eay_test);
% quiver(0*Eax_test,0*Eay_test,Eax_test,Eay_test,0);