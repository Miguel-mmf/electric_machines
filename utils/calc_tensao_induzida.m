function [Ea,jXsIa] = calc_tensao_induzida(tensao_fase,tensao_fase_angle,Ia,Ia_phase,Xs)

    jXsIa = Xs*(Ia*cosd(Ia_phase)+ 1i*Ia*sind(Ia_phase))*1i;
    %RaIa = Ra*(Ia*cosd(Ia_phase) + 1i*Ia*sind(Ia_phase));

    %% Tensão Induzida da Máquina
    Ea = tensao_fase*cosd(tensao_fase_angle) + 1i*tensao_fase*sind(tensao_fase_angle) + jXsIa;

end