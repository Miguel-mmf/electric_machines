function [Vp,Vl] = calc_tensao_fase(tensao_terminal,ligacao)
    
    if ligacao == 'y'
        Vp = tensao_terminal/sqrt(3);
        Vl = tensao_terminal;
    elseif ligacao == 'd'
        Vp = tensao_terminal;
        Vl = tensao_terminal;
    else
        printf('A informação de ligação da máquina deve ser: (y) para ligacao Y e (d) para ligacao delta.')
        ligacao = input('Informe o tipo de ligacao da máquina','s');
        if ligacao == 'y'
            Vp = tensao_terminal/sqrt(3);
        elseif ligacao == 'd'
            Vp = tensao_terminal;
        else
            printf('A informação de ligação da máquina está incorreta!')
        end
    end

end