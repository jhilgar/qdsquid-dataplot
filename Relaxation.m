classdef Relaxation < handle
% Relaxation    A class for fitting relaxation times to a model
%
%   obj = Relaxation(tauData1, tauData2, ...)
%   INPUT   tauData:    (AcData) or (DcData) object handle(s)
%   OUTPUT  obj:        (object handle)
%
%   METHODS fitRelaxation               - Fits the currently selected model
%                                         parameters to the input data over
%                                         TempRange
%           plotRelaxation(num)         - Plots a specific relaxation model
%                                         from Fits, or the most recently
%                                         fit model if num isn't passed
%           setTempRange(tempRange)     - Set the active temperature range for fitting
%           
%   PROPERTIES  Ueff, tau_0, qtm, C, n  - Initial values for fitting
%               Fits                    - (table) tau values extracted from inputs
%               VarsOut                 - (table) Output from calling fitRelaxation
%               
%   This class can take multiple sources of relaxation times as input and
%   fits them over a given temperature range to a user-supplied relaxation
%   model. The default temperature range is the entire range of the
%   combined tau inputs.
%
%   Set the desired initial model parameters (PROPERTIES) before calling
%   fitRelaxation. Set parameters that you do not wish to fit to NaN.

    properties
        Fits            = [];
        TempRange       = NaN;
        Ueff            = 100;
        tau_0           = 1e-10;
        qtm             = NaN;
        C               = NaN;
        n               = NaN;
        VarsOut         = table;
    end
    
    methods
        function obj = Relaxation(varargin)
            obj.parseTauData(varargin);
        end
        
        function setTempRange(obj, tempRange)
            if isnan(tempRange)
                obj.TempRange = [min(obj.Fits.Temperature), max(obj.Fits.Temperature)];
            else
                obj.TempRange = tempRange;
            end
        end

        function plotRelaxation(obj, varargin)
            if height(obj.VarsOut) == 0
                disp('Relaxation not yet fit.');
                return;
            end
            PlotHelper.setDefaults();
            if isempty(varargin)
                sel = height(obj.VarsOut);
            else
                sel = varargin{1};
            end
            b0 = table2array(obj.VarsOut(sel, {'Ueff', 'tau_0', 'qtm', 'C', 'n'}));
            b0 = [b0(1), 1./b0(2), 1./b0(3), b0(4), b0(5)];
            fixedSet = arrayfun(@(x) isnan(x), b0);
            fixedVals = zeros(1, sum(fixedSet));
            bvary0 = b0(~fixedSet);
            
            plot(1 ./ obj.Fits.Temperature, log(1./Relaxation.fitFunctionWrapper(bvary0, obj.Fits.Temperature, fixedSet, fixedVals)));
        end
        
        function fitRelaxation(obj)
            opts = optimoptions('lsqcurvefit', 'Algorithm', 'levenberg-marquardt', 'SpecifyObjectiveGradient', false, 'Display', 'none', ...
                'StepTolerance', 1e-15, 'FunctionTolerance', 1e-15, 'MaxFunctionEvaluations', 10000, 'MaxIterations', 3000);

            b0 = [obj.Ueff, 1./obj.tau_0, 1./obj.qtm, obj.C, obj.n];
            y = NaN(length(b0), 2);
            fixedSet = arrayfun(@(x) isnan(x), b0);
            fixedVals = zeros(1, sum(fixedSet));
            bvary0 = b0(~fixedSet);
            
            rows = obj.Fits.Temperature >= obj.TempRange(1) & obj.Fits.Temperature <= obj.TempRange(2);
            
            [b0(~fixedSet), ~, resid, ~, ~, ~, J] = lsqcurvefit(@(b, xdata) Relaxation.fitFunctionWrapper(b, xdata, fixedSet, fixedVals), bvary0, ...
                obj.Fits.Temperature(rows), 1 ./ obj.Fits.tau(rows), [], [], opts);
            y(~fixedSet, :) = nlparci(b0(~fixedSet), resid, 'Jacobian', J);
            
            obj.VarsOut      = [obj.VarsOut; ...
                array2table([min(obj.TempRange), max(obj.TempRange), b0(1), b0(1) - y(1, 1), 1./b0(2), 1./(b0(2) - y(2, 1)), ...
                1./b0(3), 1./(b0(3) - y(3, 1)), b0(4), b0(4) - y(4, 1), b0(5), b0(5) - y(5, 1)], ...
                'VariableNames', {'LowTemp', 'HighTemp', 'Ueff', 'UeffCi', 'tau_0', 'tua_0Ci', 'qtm', 'qtmCi', 'C', 'CCi', 'n', 'nCi'})];
            disp(obj.VarsOut);
        end
    end
    
    methods (Hidden)
        function parseTauData(obj, inputData)
            obj.Fits = array2table(zeros(0, 3), 'VariableNames', {'Temperature', 'tau', 'DataType'});
            for a = 1:length(inputData)
               obj.Fits = [obj.Fits; inputData{a}.Fits(:, {'Temperature', 'tau', 'DataType'})];
            end
            obj.setTempRange(NaN);
        end
    end
    
    methods (Static, Access = private)
        function output = relaxationFunction(b, xdata)
            output = b(2).*exp(-b(1)./(0.695.*xdata)) + b(3) + b(4).*xdata.^b(5);
        end
        
        function output = fitFunctionWrapper(bvary, xdata, fixedSet, fixedVals)
            b = zeros(size(fixedSet));
            b(~~fixedSet) = fixedVals;
            b(~fixedSet) = bvary;
            output = Relaxation.relaxationFunction(b, xdata);
        end
    end
end