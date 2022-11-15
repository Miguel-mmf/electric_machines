classdef interface_final_G05_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        LeftPanel                       matlab.ui.container.Panel
        VelocidadedeRotacoRotaesporMinutorpmEditField  matlab.ui.control.NumericEditField
        VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel  matlab.ui.control.Label
        InformaesdoGeradorSncronoLabel  matlab.ui.control.Label
        Vazio                           matlab.ui.container.ButtonGroup
        Procurar                        matlab.ui.control.Button
        TensaoTerminal                  matlab.ui.control.NumericEditField
        FrequenciadaRedeLabel           matlab.ui.control.Label
        ReatanciaSincrona               matlab.ui.control.NumericEditField
        ReatanciaSincronaLabel          matlab.ui.control.Label
        ResistenciadeArmadura           matlab.ui.control.NumericEditField
        ResistnciadeArmaduraLabel       matlab.ui.control.Label
        NumerodePolos                   matlab.ui.control.NumericEditField
        NumerodePolosEditFieldLabel     matlab.ui.control.Label
        TipodeFP                        matlab.ui.container.ButtonGroup
        Capacitivo                      matlab.ui.control.RadioButton
        Indutivo                        matlab.ui.control.RadioButton
        FP                              matlab.ui.control.NumericEditField
        FPEditFieldLabel                matlab.ui.control.Label
        TipodeLigacao                   matlab.ui.container.ButtonGroup
        Delta                           matlab.ui.control.RadioButton
        Y                               matlab.ui.control.RadioButton
        PotenciaAparente                matlab.ui.control.NumericEditField
        PotenciaAparenteMVaLabel        matlab.ui.control.Label
        CaracteristicaAVazio            matlab.ui.control.UIAxes
        CenterPanel                     matlab.ui.container.Panel
        TensodeTerminalpu_q01           matlab.ui.control.NumericEditField
        TensoInternaEapuLabel           matlab.ui.control.Label
        CorrentedeCampopu_q01           matlab.ui.control.NumericEditField
        CorrentedeCampopuEditFieldLabel  matlab.ui.control.Label
        CorrentedeArmadurapu_q01        matlab.ui.control.NumericEditField
        CorrentedeArmaduraLabel         matlab.ui.control.Label
        LimparGrafico2_q01              matlab.ui.control.Button
        PorcentagemdeCarga_q01          matlab.ui.control.Spinner
        PorcentagemdeCargaSpinnerLabel  matlab.ui.control.Label
        Questo1Label                    matlab.ui.control.Label
        Grafico2_q01                    matlab.ui.control.UIAxes
        Grafico1_q01                    matlab.ui.control.UIAxes
        RightPanel                      matlab.ui.container.Panel
        CorrentedeCampopu_q02           matlab.ui.control.NumericEditField
        CorrentedeCampopuEditField_2Label  matlab.ui.control.Label
        TensodeTerminalpu_q02           matlab.ui.control.NumericEditField
        TensodeTerminalpuEditFieldLabel_2  matlab.ui.control.Label
        CorrentedeArmadurapu_q02        matlab.ui.control.NumericEditField
        CorrentedeArmaduraLabel_2       matlab.ui.control.Label
        LimparGrafico1_q01              matlab.ui.control.Button
        CorrentedeCampoA_q02            matlab.ui.control.Spinner
        CorrentedeCampoASpinner_2Label  matlab.ui.control.Label
        Questo2Label                    matlab.ui.control.Label
        Grafico1_q02                    matlab.ui.control.UIAxes
        Grafico2_q02                    matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = public)
        File;
        If_x_Vt;
        poli_If_x_Vt_inv;
        Ea_temp;
        jXsIa_temp;
    end
    
    properties (Access = private)
        pot_aparente; % potência aparente do GS
        Xs; % reatância síncrona do GS
        Ra; % resistência de armadura do GS
        fp; % fator de potência (atrasado)
        fp_estado; % i - indutivo e c-capacitivo
        ligacao; % y - ligacao Y e d - ligacao delta
        num_polos; % Número de polos da máquina.
        freq_ele; % frequência elétrica em Hz.
        Vt;
        Vp;
        Vl;
        Ic_ref;
        Ia_ref;
        Il_ref;
        Ea_ref;
        %Ea_ref_comp;
        Ia_pu_q01;
        Il_pu_q01;
        Ea_pu_q01;
        Ia_pu_q02;
        Il_pu_q02;
        Ea_pu_q02;
    end
    
    
    methods (Access = public)
        
        function calc_op_nominal_gs( ...
            app, ...
            tensao_linha ...
        )        
            if app.fp_estado == "Indutivo"
                Ia_phase = -1*acosd(app.fp);
            end
            if app.fp_estado == "Capacitivo"
                Ia_phase = abs(acosd(app.fp));
            end

            if app.ligacao == 'Y'
                app.Ia_ref = app.pot_aparente/(sqrt(3)*tensao_linha);
                app.Ia_ref = app.Ia_ref*cosd(Ia_phase) + 1i*app.Ia_ref*sind(Ia_phase);
                app.Il_ref = app.Ia_ref;
            end

            if app.ligacao == "Delta"
                app.Ia_ref = app.pot_aparente/(3*tensao_linha);
                app.Ia_ref = app.Ia_ref*cosd(Ia_phase) + 1i*app.Ia_ref*sind(Ia_phase);
                app.Il_ref = app.Ia_ref*sqrt(3);
            end
            
            app.Ea_ref = app.Vp + 1i*app.Xs*app.Ia_ref;
        end
    
        function calc_tensao_fase(app)
    
            if app.ligacao == 'Y'
                app.Vp = app.Vt/sqrt(3);
                app.Vl = app.Vt;
            end
            
            if app.ligacao == "Delta"
                app.Vp = app.Vt;
                app.Vl = app.Vt;
            end
        
        end

        function [Ea,jXsIa] = calc_tensao_induzida( ...
                app, ...
                tensao_fase, ...
                tensao_fase_angle ...
              )
            
            jXsIa= 1i*app.Xs*app.Ia_ref; %1i*app.Xs*(Ia*cosd(Ia_phase)+ 1i*Ia*sind(Ia_phase));
            Ea = tensao_fase*cosd(tensao_fase_angle) + 1i*tensao_fase*sind(tensao_fase_angle) + jXsIa; %+ app.Ra*(Ia*cosd(Ia_phase)+ 1i*Ia*sind(Ia_phase));
        end
        
        function [Ia_pu,Il_pu,Ea_pu] = calc_gs_pu( ...
            app,...
            Ia, ...
            Il, ...
            Ea ...
            )
            %% Corrente de Armadura
            Ia_pu = abs(Ia)/abs(app.Ia_ref);
        
            %% Corrente de Linha
            Il_pu = abs(Il)/abs(app.Il_ref);
        
            %% Tensão Induzida
            Ea_pu = abs(Ea)/abs(app.Ea_ref);       
        end
    
        function gera_graficos01( ...
                app, ...
                ax, ...
                Ea, ...
                jXsIa, ...
                Ia ...
            )
           
            %% Plot Tensão Induzida Interna Ea
            quiver( ...
                ax, ...
                0*real(Ea), ...
                0*imag(Ea), ...
                real(Ea), ...
                imag(Ea), ...
                0, ...
                'g', ...
                'LineWidth',...
                2 ...
            );
            hold(ax,'on');
            
            %% Plot Tensão de Fase Vp
            quiver(ax,0*app.Vp,0*app.Vp,app.Vp,0*app.Vp,0,'b','LineWidth',2);

            %% Plot Corrente de Armadura Ia
            quiver( ...
                ax, ...
                0*app.Vp, ...
                0*app.Vp, ...
                real(Ia), ...
                imag(Ia), ...
                0, ...
                'r', ...
                'LineWidth',...
                2 ...
             );

            %% Plot Resistência de Armadura RaIa
%             
%             quiver( ...
%                 ax, ...
%                 app.Vp, ...
%                 0*app.Vp, ...
%                 app.Ra*real(Ia), ...
%                 imag(app.Ra*1i*imag(Ia)), ...
%                 0, ...
%                 'y', ...
%                 'LineWidth',...
%                 2 ...
%              );

            %% Plot Reatância Síncrona jXsIa
            quiver( ...
                ax, ...
                app.Vp, ...
                0, ...
                real(jXsIa), ...
                imag(jXsIa), ...
                0, ...
                'm', ...
                'LineWidth',...
                2 ...
            );
%             quiver( ...
%                 ax, ...
%                 app.Vp+app.Ra*real(Ia), ...
%                 imag(app.Ra*1i*imag(Ia)), ...
%                 real(jXsIa), ...
%                 imag(jXsIa), ...
%                 0, ...
%                 'm', ...
%                 'LineWidth',...
%                 2 ...
%             );
            %quiver(app.Grafico1_q01,app.Vp,0*app.Vp,abs(jXsIa),imag(jXsIa),0,'m');

            %legend(ax,'Ea','Vp','Ia','jXsIa','Location','southeast');

            legend( ...
                ax, ...
                sprintf('Ea (%0.2f / %0.2f°)',abs(Ea),rad2deg(angle(Ea))), ...
                sprintf('Vp (%0.2f / %0.2f°)',abs(app.Vp),rad2deg(angle(app.Vp))), ...
                sprintf('Ia (%0.2f / %0.2f°)',abs(Ia),rad2deg(angle(Ia))), ...
                sprintf('jXsIa (%0.2f / %0.2f°)',abs(jXsIa),rad2deg(angle(jXsIa))) ...
            );
            legend(ax,'boxoff');
%             text(ax,0,0,sprintf('Ea (%0.2f/%0.2f°)',abs(Ea),rad2deg(angle(Ea))));
        end
    
        function Il_novo = calc_corrente_linha( ...
                app, ...
                Ia ...
                )
            if app.ligacao == 'Y'
                Il_novo = Ia;
            end
            
            if app.ligacao == "Delta"
                Il_novo = Ia*sqrt(3);
            end
        end

        function inicial(app, Ea, jXsIa)
            %% Inicialização Questão 1

            app.PorcentagemdeCarga_q01.Value = 100;
            app.CorrentedeCampoA_q02.Value = 3.5;

            app.gera_graficos01(app.Grafico1_q01,Ea,jXsIa,app.Ia_ref);
            legend(app.Grafico1_q01,'Location','northwest');
            
            [app.Ia_pu_q01,app.Il_pu_q01,app.Ea_pu_q01] = app.calc_gs_pu(app.Ia_ref,app.Il_ref,app.Ea_ref);
            app.CorrentedeArmadurapu_q01.Value = app.Ia_pu_q01;
            app.CorrentedeCampopu_q01.Value = app.Il_pu_q01;
            app.TensodeTerminalpu_q01.Value = app.Ea_pu_q01;

            %% Inicialização Questão 2

            app.gera_graficos01(app.Grafico1_q02,Ea,jXsIa, app.Ia_ref);%(app.Ia_ref*cosd(Ia_phase) + 1i*app.Ia_ref*sind(Ia_phase)));
            legend(app.Grafico1_q02,'Location','northwest');

            [app.Ia_pu_q02,app.Il_pu_q02,app.Ea_pu_q02] = app.calc_gs_pu(app.Ia_ref,app.Il_ref,app.Ea_ref);
            app.CorrentedeArmadurapu_q02.Value = app.Ia_pu_q02;
            app.CorrentedeCampopu_q02.Value = app.Il_pu_q02;
            app.TensodeTerminalpu_q02.Value = app.Ea_pu_q02;
        end

        function questao1(app)

            y = asind(((app.pot_aparente*app.PorcentagemdeCarga_q01.Value/100)*app.fp*app.Xs)/(3*app.Vp*abs(app.Ea_ref)));
            Ea_novo = abs(app.Ea_ref)*cosd(y) + 1i*abs(app.Ea_ref)*sind(y);
            
            % Calculo do Ia
            Ia_novo = (Ea_novo - app.Vp)/(1i*app.Xs);
            
            % Calculo jXsIa 
            jXsIa_novo = Ia_novo*(1i*app.Xs);

            % Calculo do FP
            fp_novo = cos(angle(Ia_novo));
            
            % Calculo da Il
            Il_novo = app.calc_corrente_linha(Ia_novo);
            
            % Gráfico 1 - Questão 1
            cla(app.Grafico1_q01);
            app.gera_graficos01(app.Grafico1_q01,Ea_novo,jXsIa_novo,Ia_novo);
            legend(app.Grafico1_q01,'Location','northwest');
            legend(app.Grafico2_q01,'Location','northwest');

            % Gráfico 2 - Questão 1
            app.gera_graficos01(app.Grafico2_q01,Ea_novo,jXsIa_novo,Ia_novo);
            title(app.Grafico1_q01,sprintf('Diagrama Fasorial - FP: %0.2f',fp_novo));
            title(app.Grafico2_q01,'Diagramas Fasoriais - Variação de Carga');
            
            raio = abs(Ea_novo);
            x = (raio-2):0.01:raio;
            y = sqrt(raio^2 - x.^2);

            plot(app.Grafico2_q01,x,y,'LineWidth',1.5,'Color','black','DisplayName','Arco');

            [app.Ia_pu_q01,app.Il_pu_q01,app.Ea_pu_q01] = app.calc_gs_pu(Ia_novo,Il_novo,Ea_novo);
            app.CorrentedeArmadurapu_q01.Value = app.Ia_pu_q01;
            app.CorrentedeCampopu_q01.Value = app.Il_pu_q01;
            app.TensodeTerminalpu_q01.Value = app.Ea_pu_q01;

        end
        
        function questao2(app)
            % Valor da Corrente de Campo Nominal
            app.poli_If_x_Vt_inv = polyfit(app.If_x_Vt.Value.VT,app.If_x_Vt.Value.IF, 4);
            app.Ic_ref = polyval(app.poli_If_x_Vt_inv, app.Vt*1000);
            
            % calculo Ea
            Ea_novo = abs(app.Ea_ref)*(app.CorrentedeCampoA_q02.Value/app.Ic_ref);
            y = asind((abs(app.Ea_ref)/abs(Ea_novo))*sin(angle(app.Ea_ref)));
            Ea_novo = Ea_novo*cosd(y) + 1i*Ea_novo*sind(y);
            % Calculo do Ia
            Ia_novo = (Ea_novo - app.Vp)/(1i*app.Xs);
            % Calculo jXsIa 
            jXsIa_novo = Ia_novo*(1i*app.Xs);
            % Calculo do FP
            fp_novo = cos(angle(Ia_novo));
            % Calculo da Il
            Il_novo = app.calc_corrente_linha(Ia_novo);
            % Gráfico 1 - Questão 2
            cla(app.Grafico1_q02);
            app.gera_graficos01(app.Grafico1_q02,Ea_novo,jXsIa_novo,Ia_novo);

            % Gráfico 2 - Questão 2
            app.gera_graficos01(app.Grafico2_q02,Ea_novo,jXsIa_novo,Ia_novo);
            title(app.Grafico1_q02,sprintf('Diagrama Fasorial - FP: %0.2f',fp_novo));
            title(app.Grafico2_q02,'Diagramas Fasoriais - Variação da Corrente de Campo (IF)');
            legend(app.Grafico1_q02,'Location','southeast');
            legend(app.Grafico2_q02,'Location','southeast');

            x = real(app.Ea_ref):0.01:(real(app.Ea_ref)+25);
            c = imag(Ea_novo);
            const = @(x)(c).*x.^(0);

            plot(app.Grafico2_q02,x,const(x),'LineWidth',1.5,'Color','black','DisplayName','Reta');

            [app.Ia_pu_q02,app.Il_pu_q02,app.Ea_pu_q02] = app.calc_gs_pu(Ia_novo,Il_novo,Ea_novo);
            app.CorrentedeArmadurapu_q02.Value = app.Ia_pu_q02;
            app.CorrentedeCampopu_q02.Value = app.Il_pu_q02;
            app.TensodeTerminalpu_q02.Value = app.Ea_pu_q02;

        end
    end
    %end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.pot_aparente = app.PotenciaAparente.Value; % potência aparente do GS
            app.Xs = app.ReatanciaSincrona.Value; % reatância síncrona do GS
            app.Ra = app.ResistenciadeArmadura.Value; % resistência de armadura do GS
            app.fp = app.FP.Value; % fator de potência
            app.fp_estado = app.TipodeFP.SelectedObject.Text; % i - indutivo e c-capacitivo
            app.ligacao = app.TipodeLigacao.SelectedObject.Text; % y - ligacao Y e d - ligacao delta
            app.Vt = app.TensaoTerminal.Value; % tensão de terminal do GS
            app.num_polos = app.NumerodePolos.Value; % Número de polos da máquina.
            app.freq_ele = 60;

            %% Inicialização Geral
            app.VelocidadedeRotacoRotaesporMinutorpmEditField.Value = (app.freq_ele*120)/app.num_polos;
            app.calc_tensao_fase();
            app.calc_op_nominal_gs(app.Vt);

            [Ea,jXsIa]  = app.calc_tensao_induzida( ...
                app.Vp, ...
                0 ...
             );

            app.inicial(Ea, jXsIa);
            title(app.Grafico1_q01, "Diagrama Fasorial na carga nominal");
            title(app.Grafico1_q02, "Diagrama Fasorial com valores nominais");
            
        end

        % Button pushed function: Procurar
        function ProcurarButtonPushed(app, event)
            
            [file,fpath] = uigetfile('./*.csv');
            app.File.Value = [fpath,file];
            ds = datastore(app.File.Value);

            app.If_x_Vt.Value = readall(ds);
            
            x = 0:0.01:10;
            poli_If_x_Vt = polyfit(app.If_x_Vt.Value.IF,app.If_x_Vt.Value.VT, 4);
            f = polyval(poli_If_x_Vt , x);

            cla(app.Grafico1_q01);
            cla(app.Grafico2_q01);
            cla(app.Grafico1_q02);
            cla(app.Grafico2_q02);
            
            plot( ...
                app.CaracteristicaAVazio, ...
                app.If_x_Vt.Value.IF, ...
                app.If_x_Vt.Value.VT, ...
                "Color","b", ...
                'Marker','o');
            hold(app.CaracteristicaAVazio,'on');
            plot( ...
                app.CaracteristicaAVazio, ...
                x, ...
                f, ...
                "Color","r", ...
                'LineStyle','-', ...
                'LineWidth',1.5 ...
            );
            grid(app.CaracteristicaAVazio,'on');
            
            %% Configuração de botões
            app.PorcentagemdeCarga_q01.Value = 60;
            app.CorrentedeCampoA_q02.Value = 6;
            app.CorrentedeCampoA_q02.Limits = [min(app.If_x_Vt.Value.IF) max(app.If_x_Vt.Value.IF)];

            %% Inicialização Questão 1
            app.questao1();
            
            %% Inicialização Questão 2
            app.questao2();
            
        end

        % Value changed function: NumerodePolos
        function NumerodePolosValueChanged(app, event)
            value = app.NumerodePolos.Value;
            app.VelocidadedeRotacoRotaesporMinutorpmEditField.Value = (app.freq_ele*120)/value;
        end

        % Callback function: FP, PotenciaAparente, ReatanciaSincrona, 
        % ...and 4 other components
        function TipodeLigacaoSelectionChanged(app, event)
            cla(app.Grafico1_q01);
            cla(app.Grafico2_q01);
            cla(app.Grafico1_q02);
            cla(app.Grafico2_q02);

            app.ligacao = app.TipodeLigacao.SelectedObject.Text;
            app.fp_estado = app.TipodeFP.SelectedObject.Text;
            app.pot_aparente = app.PotenciaAparente.Value;
            app.Xs = app.ReatanciaSincrona.Value;
            app.Ra = app.ResistenciadeArmadura.Value;
            app.fp = app.FP.Value;
            app.Vt = app.TensaoTerminal.Value;
            app.calc_tensao_fase();
                app.calc_op_nominal_gs(app.Vt);
    
                [Ea,jXsIa]  = app.calc_tensao_induzida( ...
                    app.Vp, ...
                    0 ...
                );

            try
                %% Inicialização Questão 2
                app.questao2();

                %% Inicialização Questão 1
                app.questao1();

            catch
                
                app.inicial(Ea, jXsIa);

                cla(app.Grafico1_q02);
                cla(app.Grafico2_q02);

            end

        end

        % Button pushed function: LimparGrafico2_q01
        function LimparGrafico2_q01ButtonPushed(app, event)
            cla(app.Grafico2_q01);
        end

        % Button pushed function: LimparGrafico1_q01
        function LimparGrafico1_q01ButtonPushed(app, event)
            cla(app.Grafico2_q02);
        end

        % Value changed function: CorrentedeCampoA_q02
        function CorrentedeCampoA_q02ValueChanged(app, event)
            app.questao2();
        end

        % Value changed function: PorcentagemdeCarga_q01
        function PorcentagemdeCarga_q01ValueChanged(app, event)
            app.questao1();
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {599, 599, 599};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {599, 599};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x', 433};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1073 599];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x', 433};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create CaracteristicaAVazio
            app.CaracteristicaAVazio = uiaxes(app.LeftPanel);
            xlabel(app.CaracteristicaAVazio, 'Corrente de Campo (A)')
            ylabel(app.CaracteristicaAVazio, 'Tensão de Terminal (kV)')
            zlabel(app.CaracteristicaAVazio, 'Z')
            app.CaracteristicaAVazio.Color = 'none';
            app.CaracteristicaAVazio.Position = [11 15 202 193];

            % Create PotenciaAparenteMVaLabel
            app.PotenciaAparenteMVaLabel = uilabel(app.LeftPanel);
            app.PotenciaAparenteMVaLabel.HorizontalAlignment = 'right';
            app.PotenciaAparenteMVaLabel.WordWrap = 'on';
            app.PotenciaAparenteMVaLabel.Position = [11 447 140 30];
            app.PotenciaAparenteMVaLabel.Text = 'Potencia Aparente (MVa)';

            % Create PotenciaAparente
            app.PotenciaAparente = uieditfield(app.LeftPanel, 'numeric');
            app.PotenciaAparente.Limits = [0 Inf];
            app.PotenciaAparente.ValueChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.PotenciaAparente.HorizontalAlignment = 'center';
            app.PotenciaAparente.Position = [161 455 49 22];
            app.PotenciaAparente.Value = 50;

            % Create TipodeLigacao
            app.TipodeLigacao = uibuttongroup(app.LeftPanel);
            app.TipodeLigacao.SelectionChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.TipodeLigacao.Title = 'Tipo de Ligação';
            app.TipodeLigacao.Position = [11 480 100 70];

            % Create Y
            app.Y = uiradiobutton(app.TipodeLigacao);
            app.Y.Text = 'Y';
            app.Y.Position = [11 24 58 22];
            app.Y.Value = true;

            % Create Delta
            app.Delta = uiradiobutton(app.TipodeLigacao);
            app.Delta.Text = 'Delta';
            app.Delta.Position = [11 2 65 22];

            % Create FPEditFieldLabel
            app.FPEditFieldLabel = uilabel(app.LeftPanel);
            app.FPEditFieldLabel.HorizontalAlignment = 'right';
            app.FPEditFieldLabel.Position = [17 423 25 22];
            app.FPEditFieldLabel.Text = 'FP';

            % Create FP
            app.FP = uieditfield(app.LeftPanel, 'numeric');
            app.FP.Limits = [0 1];
            app.FP.ValueChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.FP.Position = [57 423 37 22];
            app.FP.Value = 0.9;

            % Create TipodeFP
            app.TipodeFP = uibuttongroup(app.LeftPanel);
            app.TipodeFP.SelectionChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.TipodeFP.Title = 'Tipo de FP';
            app.TipodeFP.Position = [111 479 100 71];

            % Create Indutivo
            app.Indutivo = uiradiobutton(app.TipodeFP);
            app.Indutivo.Text = 'Indutivo';
            app.Indutivo.Position = [11 25 64 22];
            app.Indutivo.Value = true;

            % Create Capacitivo
            app.Capacitivo = uiradiobutton(app.TipodeFP);
            app.Capacitivo.Text = 'Capacitivo';
            app.Capacitivo.Position = [11 3 78 22];

            % Create NumerodePolosEditFieldLabel
            app.NumerodePolosEditFieldLabel = uilabel(app.LeftPanel);
            app.NumerodePolosEditFieldLabel.HorizontalAlignment = 'right';
            app.NumerodePolosEditFieldLabel.Position = [111 416 51 30];
            app.NumerodePolosEditFieldLabel.Text = {'Numero '; 'de Polos'};

            % Create NumerodePolos
            app.NumerodePolos = uieditfield(app.LeftPanel, 'numeric');
            app.NumerodePolos.Limits = [1 Inf];
            app.NumerodePolos.ValueChangedFcn = createCallbackFcn(app, @NumerodePolosValueChanged, true);
            app.NumerodePolos.Position = [177 424 33 22];
            app.NumerodePolos.Value = 4;

            % Create ResistnciadeArmaduraLabel
            app.ResistnciadeArmaduraLabel = uilabel(app.LeftPanel);
            app.ResistnciadeArmaduraLabel.Interpreter = 'html';
            app.ResistnciadeArmaduraLabel.Position = [21 384 141 30];
            app.ResistnciadeArmaduraLabel.Text = 'Resistência de Armadura';

            % Create ResistenciadeArmadura
            app.ResistenciadeArmadura = uieditfield(app.LeftPanel, 'numeric');
            app.ResistenciadeArmadura.Limits = [0 Inf];
            app.ResistenciadeArmadura.ValueChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.ResistenciadeArmadura.Position = [171 392 39 22];
            app.ResistenciadeArmadura.Value = 0.2;

            % Create ReatanciaSincronaLabel
            app.ReatanciaSincronaLabel = uilabel(app.LeftPanel);
            app.ReatanciaSincronaLabel.Position = [21 357 140 30];
            app.ReatanciaSincronaLabel.Text = 'Reatancia Sincrona';

            % Create ReatanciaSincrona
            app.ReatanciaSincrona = uieditfield(app.LeftPanel, 'numeric');
            app.ReatanciaSincrona.Limits = [0 Inf];
            app.ReatanciaSincrona.ValueChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.ReatanciaSincrona.Position = [171 365 39 22];
            app.ReatanciaSincrona.Value = 2.5;

            % Create FrequenciadaRedeLabel
            app.FrequenciadaRedeLabel = uilabel(app.LeftPanel);
            app.FrequenciadaRedeLabel.Position = [20 331 140 30];
            app.FrequenciadaRedeLabel.Text = 'Tensão de Terminal (kV)';

            % Create TensaoTerminal
            app.TensaoTerminal = uieditfield(app.LeftPanel, 'numeric');
            app.TensaoTerminal.Limits = [0 Inf];
            app.TensaoTerminal.ValueChangedFcn = createCallbackFcn(app, @TipodeLigacaoSelectionChanged, true);
            app.TensaoTerminal.Position = [171 339 40 22];
            app.TensaoTerminal.Value = 13.8;

            % Create Vazio
            app.Vazio = uibuttongroup(app.LeftPanel);
            app.Vazio.Title = 'Caracteristica a Vazio';
            app.Vazio.Position = [11 256 200 71];

            % Create Procurar
            app.Procurar = uibutton(app.Vazio, 'push');
            app.Procurar.ButtonPushedFcn = createCallbackFcn(app, @ProcurarButtonPushed, true);
            app.Procurar.Position = [8 15 183 23];
            app.Procurar.Text = 'Procurar';

            % Create InformaesdoGeradorSncronoLabel
            app.InformaesdoGeradorSncronoLabel = uilabel(app.LeftPanel);
            app.InformaesdoGeradorSncronoLabel.HorizontalAlignment = 'center';
            app.InformaesdoGeradorSncronoLabel.WordWrap = 'on';
            app.InformaesdoGeradorSncronoLabel.FontSize = 20;
            app.InformaesdoGeradorSncronoLabel.FontWeight = 'bold';
            app.InformaesdoGeradorSncronoLabel.Position = [1 553 213 45];
            app.InformaesdoGeradorSncronoLabel.Text = 'Informações do Gerador Síncrono';

            % Create VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel
            app.VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel = uilabel(app.LeftPanel);
            app.VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel.HorizontalAlignment = 'center';
            app.VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel.WordWrap = 'on';
            app.VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel.Position = [11 222 151 28];
            app.VelocidadedeRotacoRotaesporMinutorpmEditFieldLabel.Text = {'Velocidade de Rotacão'; 'Rotações por Minuto (rpm)'};

            % Create VelocidadedeRotacoRotaesporMinutorpmEditField
            app.VelocidadedeRotacoRotaesporMinutorpmEditField = uieditfield(app.LeftPanel, 'numeric');
            app.VelocidadedeRotacoRotaesporMinutorpmEditField.Editable = 'off';
            app.VelocidadedeRotacoRotaesporMinutorpmEditField.Position = [161 222 49 28];

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create Grafico1_q01
            app.Grafico1_q01 = uiaxes(app.CenterPanel);
            app.Grafico1_q01.Color = 'none';
            app.Grafico1_q01.Position = [11 331 400 197];

            % Create Grafico2_q01
            app.Grafico2_q01 = uiaxes(app.CenterPanel);
            app.Grafico2_q01.XColor = [0 0 0];
            app.Grafico2_q01.Color = 'none';
            app.Grafico2_q01.Position = [11 7 400 251];

            % Create Questo1Label
            app.Questo1Label = uilabel(app.CenterPanel);
            app.Questo1Label.HorizontalAlignment = 'center';
            app.Questo1Label.WordWrap = 'on';
            app.Questo1Label.FontSize = 20;
            app.Questo1Label.FontWeight = 'bold';
            app.Questo1Label.Position = [31 573 360 25];
            app.Questo1Label.Text = 'Questão 1';

            % Create PorcentagemdeCargaSpinnerLabel
            app.PorcentagemdeCargaSpinnerLabel = uilabel(app.CenterPanel);
            app.PorcentagemdeCargaSpinnerLabel.HorizontalAlignment = 'right';
            app.PorcentagemdeCargaSpinnerLabel.Position = [99 536 152 22];
            app.PorcentagemdeCargaSpinnerLabel.Text = 'Porcentagem de Carga (%)';

            % Create PorcentagemdeCarga_q01
            app.PorcentagemdeCarga_q01 = uispinner(app.CenterPanel);
            app.PorcentagemdeCarga_q01.Step = 10;
            app.PorcentagemdeCarga_q01.Limits = [0 100];
            app.PorcentagemdeCarga_q01.ValueChangedFcn = createCallbackFcn(app, @PorcentagemdeCarga_q01ValueChanged, true);
            app.PorcentagemdeCarga_q01.Position = [261 536 49 22];
            app.PorcentagemdeCarga_q01.Value = 60;

            % Create LimparGrafico2_q01
            app.LimparGrafico2_q01 = uibutton(app.CenterPanel, 'push');
            app.LimparGrafico2_q01.ButtonPushedFcn = createCallbackFcn(app, @LimparGrafico2_q01ButtonPushed, true);
            app.LimparGrafico2_q01.Position = [11 257 73 25];
            app.LimparGrafico2_q01.Text = 'Limpar';

            % Create CorrentedeArmaduraLabel
            app.CorrentedeArmaduraLabel = uilabel(app.CenterPanel);
            app.CorrentedeArmaduraLabel.HorizontalAlignment = 'center';
            app.CorrentedeArmaduraLabel.WordWrap = 'on';
            app.CorrentedeArmaduraLabel.Position = [11 287 89 28];
            app.CorrentedeArmaduraLabel.Text = {'Corrente de'; 'Armadura (pu)'};

            % Create CorrentedeArmadurapu_q01
            app.CorrentedeArmadurapu_q01 = uieditfield(app.CenterPanel, 'numeric');
            app.CorrentedeArmadurapu_q01.Editable = 'off';
            app.CorrentedeArmadurapu_q01.HorizontalAlignment = 'center';
            app.CorrentedeArmadurapu_q01.Position = [99 289 33 30];

            % Create CorrentedeCampopuEditFieldLabel
            app.CorrentedeCampopuEditFieldLabel = uilabel(app.CenterPanel);
            app.CorrentedeCampopuEditFieldLabel.HorizontalAlignment = 'center';
            app.CorrentedeCampopuEditFieldLabel.WordWrap = 'on';
            app.CorrentedeCampopuEditFieldLabel.Position = [144 285 89 28];
            app.CorrentedeCampopuEditFieldLabel.Text = {'Corrente de'; 'Campo (pu)'};

            % Create CorrentedeCampopu_q01
            app.CorrentedeCampopu_q01 = uieditfield(app.CenterPanel, 'numeric');
            app.CorrentedeCampopu_q01.Editable = 'off';
            app.CorrentedeCampopu_q01.HorizontalAlignment = 'center';
            app.CorrentedeCampopu_q01.Position = [232 287 33 30];

            % Create TensoInternaEapuLabel
            app.TensoInternaEapuLabel = uilabel(app.CenterPanel);
            app.TensoInternaEapuLabel.HorizontalAlignment = 'center';
            app.TensoInternaEapuLabel.WordWrap = 'on';
            app.TensoInternaEapuLabel.Position = [290 287 89 28];
            app.TensoInternaEapuLabel.Text = {'Tensão Interna '; 'Ea (pu)'};

            % Create TensodeTerminalpu_q01
            app.TensodeTerminalpu_q01 = uieditfield(app.CenterPanel, 'numeric');
            app.TensodeTerminalpu_q01.Editable = 'off';
            app.TensodeTerminalpu_q01.HorizontalAlignment = 'center';
            app.TensodeTerminalpu_q01.Position = [378 289 33 30];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create Grafico2_q02
            app.Grafico2_q02 = uiaxes(app.RightPanel);
            app.Grafico2_q02.Color = 'none';
            app.Grafico2_q02.Position = [12 10 400 251];

            % Create Grafico1_q02
            app.Grafico1_q02 = uiaxes(app.RightPanel);
            app.Grafico1_q02.Color = 'none';
            app.Grafico1_q02.Position = [15 331 400 197];

            % Create Questo2Label
            app.Questo2Label = uilabel(app.RightPanel);
            app.Questo2Label.HorizontalAlignment = 'center';
            app.Questo2Label.WordWrap = 'on';
            app.Questo2Label.FontSize = 20;
            app.Questo2Label.FontWeight = 'bold';
            app.Questo2Label.Position = [31 572 360 26];
            app.Questo2Label.Text = 'Questão 2';

            % Create CorrentedeCampoASpinner_2Label
            app.CorrentedeCampoASpinner_2Label = uilabel(app.RightPanel);
            app.CorrentedeCampoASpinner_2Label.HorizontalAlignment = 'right';
            app.CorrentedeCampoASpinner_2Label.Position = [121 536 130 22];
            app.CorrentedeCampoASpinner_2Label.Text = 'Corrente de Campo (A)';

            % Create CorrentedeCampoA_q02
            app.CorrentedeCampoA_q02 = uispinner(app.RightPanel);
            app.CorrentedeCampoA_q02.Limits = [0 100];
            app.CorrentedeCampoA_q02.ValueChangedFcn = createCallbackFcn(app, @CorrentedeCampoA_q02ValueChanged, true);
            app.CorrentedeCampoA_q02.Position = [261 536 49 22];
            app.CorrentedeCampoA_q02.Value = 6;

            % Create LimparGrafico1_q01
            app.LimparGrafico1_q01 = uibutton(app.RightPanel, 'push');
            app.LimparGrafico1_q01.ButtonPushedFcn = createCallbackFcn(app, @LimparGrafico1_q01ButtonPushed, true);
            app.LimparGrafico1_q01.Position = [13 257 73 25];
            app.LimparGrafico1_q01.Text = 'Limpar';

            % Create CorrentedeArmaduraLabel_2
            app.CorrentedeArmaduraLabel_2 = uilabel(app.RightPanel);
            app.CorrentedeArmaduraLabel_2.HorizontalAlignment = 'center';
            app.CorrentedeArmaduraLabel_2.WordWrap = 'on';
            app.CorrentedeArmaduraLabel_2.Position = [12 289 89 28];
            app.CorrentedeArmaduraLabel_2.Text = {'Corrente de'; 'Armadura (pu)'};

            % Create CorrentedeArmadurapu_q02
            app.CorrentedeArmadurapu_q02 = uieditfield(app.RightPanel, 'numeric');
            app.CorrentedeArmadurapu_q02.Editable = 'off';
            app.CorrentedeArmadurapu_q02.HorizontalAlignment = 'center';
            app.CorrentedeArmadurapu_q02.Position = [100 291 33 30];

            % Create TensodeTerminalpuEditFieldLabel_2
            app.TensodeTerminalpuEditFieldLabel_2 = uilabel(app.RightPanel);
            app.TensodeTerminalpuEditFieldLabel_2.HorizontalAlignment = 'center';
            app.TensodeTerminalpuEditFieldLabel_2.WordWrap = 'on';
            app.TensodeTerminalpuEditFieldLabel_2.Position = [291 289 89 28];
            app.TensodeTerminalpuEditFieldLabel_2.Text = {'Tensão Interna'; 'Ea (pu)'};

            % Create TensodeTerminalpu_q02
            app.TensodeTerminalpu_q02 = uieditfield(app.RightPanel, 'numeric');
            app.TensodeTerminalpu_q02.Editable = 'off';
            app.TensodeTerminalpu_q02.HorizontalAlignment = 'center';
            app.TensodeTerminalpu_q02.Position = [379 291 33 30];

            % Create CorrentedeCampopuEditField_2Label
            app.CorrentedeCampopuEditField_2Label = uilabel(app.RightPanel);
            app.CorrentedeCampopuEditField_2Label.HorizontalAlignment = 'center';
            app.CorrentedeCampopuEditField_2Label.WordWrap = 'on';
            app.CorrentedeCampopuEditField_2Label.Position = [145 287 89 28];
            app.CorrentedeCampopuEditField_2Label.Text = {'Corrente de'; 'Campo (pu)'};

            % Create CorrentedeCampopu_q02
            app.CorrentedeCampopu_q02 = uieditfield(app.RightPanel, 'numeric');
            app.CorrentedeCampopu_q02.Editable = 'off';
            app.CorrentedeCampopu_q02.HorizontalAlignment = 'center';
            app.CorrentedeCampopu_q02.Position = [233 289 33 30];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = interface_final_G05_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end