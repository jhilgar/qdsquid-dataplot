classdef AcData < TauData
% AcData        A class for parsing and fitting ac susceptibilities
%
%   obj = AcData(filename)
%   INPUT   filename:   (string)
%   OUTPUT  obj:        (object handle)
%
%   METHODS plotArrhenius           - Outputs an Arrhenius plot of the tau data
%           plotInPhase             - Plots the in-phase susceptibility
%           plotOutOfPhase          - Plots the out-of-phase susceptibility
%           plotColeCole            - Outputs a Cole-Cole plot
%           setTempRange(tempRange) - Sets the data selection range to (1x2
%                                     vector) tempRange
%
%   PROPERTIES  Fits        - (table) Debye model fits of the input data over
%                             TempRange
%               TempRange   - Currently selected temperature range
%               
%   This class automatically fits ac susceptibilities upon creation to a generalized
%   Debye model. It excludes relaxation times which are outside the MPMS 3 ac 
%   frequency limits (0.1-1000 Hz) by default.
%
%   Type `help Relaxation` for details on how to fit these data to a
%   relaxation model.

    methods
        function obj = AcData(filename)
            obj = obj@TauData(filename);
            
            obj.parseTauData(obj.TempRange);
            obj.fitTau();
        end
        
        function plotArrhenius(obj)
            % AcData.plotArrhenius
            %
            % See PlotHelper.setArrheniusAxes()

            PlotHelper.setDefaults();
            scatter(1 ./ obj.Fits.Temperature, log(obj.Fits.tau), [], PlotHelper.dataColor(obj.Fits.Temperature), 'filled');
            xlabel('1/T (K^{-1})'); ylabel('ln(\tau)');
        end
        
        function plotInPhase(obj)
            % AcData.plotInPhase
            
            PlotHelper.setDefaults();
            for a = 1:length(obj.Fits.Temperature)
                rows = obj.Parsed.TemperatureRounded == obj.Fits.Temperature(a);
                scatter(obj.Parsed.Frequency(rows), obj.Parsed.ChiIn(rows), [], PlotHelper.dataColor(obj.Fits.Temperature(a)), 'filled');
                plot(obj.Parsed.Frequency(rows), obj.Parsed.ChiInCalc(rows), 'Color', [0 0 0]);
            end
            xlabel('Frequency (Hz)'); ylabel('\chi\prime (emu mol^{-1})');
            set(gca, 'XScale', 'log');
        end
        
        function plotOutOfPhase(obj)
            % AcData.plotOutOfPhase
            
            PlotHelper.setDefaults();
            for a = 1:length(obj.Fits.Temperature)
                rows = obj.Parsed.TemperatureRounded == obj.Fits.Temperature(a);
                scatter(obj.Parsed.Frequency(rows), obj.Parsed.ChiOut(rows), [], PlotHelper.dataColor(obj.Fits.Temperature(a)), 'filled');
                plot(obj.Parsed.Frequency(rows), obj.Parsed.ChiOutCalc(rows), 'Color', [0 0 0]);
            end
            xlabel('Frequency (Hz)'); ylabel('\chi\prime\prime (emu mol^{-1})');
            set(gca, 'XScale', 'log');
        end
        
        function plotColeCole(obj)
            % AcData.plotColeCole
            
            PlotHelper.setDefaults();
            for a = 1:length(obj.Fits.Temperature)
                rows = obj.Parsed.TemperatureRounded == obj.Fits.Temperature(a);
                scatter(obj.Parsed.ChiIn(rows), obj.Parsed.ChiOut(rows), [], PlotHelper.dataColor(obj.Fits.Temperature(a)), 'filled');
                plot(obj.Parsed.ChiInCalc(rows), obj.Parsed.ChiOutCalc(rows), 'Color', [0 0 0]);
            end
            xlabel('\chi\prime (emu mol^{-1})'); ylabel('\chi\prime\prime (emu mol^{-1})');
        end
        
        function setTempRange(obj, tempRange)
            % AcData.setTempRange(tempRange)
            % INPUT     (1x2 vector) temperature range to include for fitting
            %
            % EXAMPLE   obj.setTempRange([10 15.5])
            
            obj.parseTauData(tempRange);
            obj.fitTau();
        end
    end
    
    methods (Hidden)
        function parseTauData(obj, tempRange)
            obj.Parsed                      = table(obj.Raw.Temperature_K_, 'VariableNames', {'Temperature'});
            obj.Parsed.TemperatureRounded   = round(obj.Parsed.Temperature / 0.05) * 0.05;
            obj.Parsed.Field                = obj.Raw.MagneticField_Oe_;
            obj.Parsed.Frequency            = obj.Raw.ACFrequency_Hz_;
            obj.Parsed.ChiIn                = obj.Raw.ACX__emu_Oe_ / obj.Header.Moles;
            obj.Parsed.ChiInError           = obj.Raw.ACX_StdErr__emu_Oe_;
            obj.Parsed.ChiOut               = obj.Raw.ACX___emu_Oe_ / obj.Header.Moles;
            obj.Parsed.ChiOutError          = obj.Raw.ACX__StdErr__emu_Oe_;
            
            toDelete = obj.Parsed.ChiIn < -1e-7 | obj.Parsed.ChiOut < -1e-7 | obj.Parsed.ChiInError > 5e-7 | obj.Parsed.ChiOutError > 5e-7;
            if ~isnan(tempRange)
                toDelete = toDelete | obj.Parsed.TemperatureRounded < tempRange(1) | obj.Parsed.TemperatureRounded > tempRange(2);
            end
            obj.Parsed(toDelete,:) = [];
            obj.TempRange = [min(obj.Parsed.TemperatureRounded), max(obj.Parsed.TemperatureRounded)];
        end
        
        function fitTau(obj)
            obj.Fits = array2table(unique(obj.Parsed.TemperatureRounded), 'VariableNames', {'Temperature'});
            
            opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');
            x0 = [0.37819, 0.057845, 0.12786, 0.00097048];
            lb = [0, 0, 0, 0];
            ub = [100, 100, 1, 5];

            for a = 1:length(obj.Fits.Temperature)
                rows = obj.Parsed.TemperatureRounded == obj.Fits.Temperature(a);
                
                [x0, ~, resid, ~, ~, ~, J] = ...
                    lsqcurvefit(@obj.fitFunction, x0, obj.Parsed.Frequency(rows), [obj.Parsed.ChiIn(rows), obj.Parsed.ChiOut(rows)], lb, ub, opts);
                y = nlparci(x0, resid, 'Jacobian', J);
                
                model = obj.fitFunction(x0, obj.Parsed.Frequency(rows));
                obj.Parsed.ChiInCalc(rows) = model(:, 1); obj.Parsed.ChiOutCalc(rows) = model(:, 2);
                obj.Fits.DataType(a, :) = 'AcData';
                obj.Fits.tau(a) = x0(4); obj.Fits.tauCi(a) = obj.Fits.tau(a) - y(4, 1);
                obj.Fits.Xt(a) = x0(1); obj.Fits.XtCi(a) = obj.Fits.Xt(a) - y(1, 1); 
                obj.Fits.Xs(a) = x0(2); obj.Fits.XsCi(a) = obj.Fits.Xs(a) - y(2, 1);
                obj.Fits.alpha(a) = x0(3); obj.Fits.alphaCi(a) = obj.Fits.alpha(a) - y(3, 1); 
            end
            
            removeTemps = obj.Fits.Temperature(obj.Fits.tau > 1/(0.1 * 2 * pi) | obj.Fits.tau < 1/(1000 * 2 * pi));
            obj.Fits(ismember(obj.Fits.Temperature, removeTemps), :) = [];
            obj.Parsed(ismember(obj.Parsed.TemperatureRounded, removeTemps), :) = [];
        end
    end
    
    methods (Static, Access = private)
       function model = fitFunction(b, x)
            x = 2 * pi .* x;
            model(:,1) = b(2) + (b(1) - b(2)) * ((1 + power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2)) ./ (1 + 2 * power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2) + power(x * b(4), 2 * (1 - b(3)))));
            model(:,2) = (b(1) - b(2)) * power(x * b(4), 1 - b(3)) * cos(pi * b(3) / 2) ./ ((1 + 2 * power(x * b(4), 1 - b(3)) * sin(pi * b(3) / 2) + power(x * b(4), (2 * (1 - b(3))))));
       end
    end
end