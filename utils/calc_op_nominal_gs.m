function [Ia_ref,Il_ref,Ea_ref] = calc_op_nominal_gs( ...
    tensao_linha, ...
    ligacao, ...
    pot_aparente, ...
    Xs)
    %% Corrente de Armadura e Corrente de Linha Máxima

    if ligacao == 'y'
        Ia_ref = pot_aparente/(sqrt(3)*tensao_linha); %Fp = 1?
        Il_ref = Ia_ref;
    elseif ligacao == 'd'
        Ia_ref = pot_aparente/(3*tensao_linha);
        Il_ref = Ia_ref*sqrt(3);
    else
        printf('A informação de ligação da máquina deve ser: (y) para ligacao Y e (d) para ligacao delta.')
        ligacao = input('Informe o tipo de ligacao da máquina','s');
        if ligacao == 'y'
            Ia_ref = pot_aparente/(sqrt(3)*tensao_linha);
            Il_ref = Ia_ref;
        elseif ligacao == 'd'
            Ia_ref = pot_aparente/(sqrt(3)*tensao_linha);
            Il_ref = Ia_ref*sqrt(3);
        else
            printf('A informação de ligação da máquina está incorreta!')
        end
    end

    %% Impedância Interna da Máquina
    %Z_ref = sqrt((Xs^2 + Ra^2));
    
    %% Tensão Interna Máxima da Máquina
    Ea_ref = Xs*Ia_ref;

end