classdef DebyeData < TauData
    properties (Access = protected)
        FitOpts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');
        x0 = [0.37819, 0.057845, 0.12786, 0.00097048]; % [Xt, Xs, alpha, tau]
        lb = [0, 0, 0, 0];
        ub = [100, 100, 1, 10000];    
    end
    
    properties (Access = protected, Constant)
        ErrorFields = {'TemperatureRounded', 'XtCiNeg', 'XtCiPos', 'XsCiNeg', 'XsCiPos', 'alphaCiNeg', 'alphaCiPos', 'tauCiNeg', 'tauCiPos'};
        FitFields = {'TemperatureRounded', 'Xt', 'Xs', 'alpha', 'tau'};
        ModelFields = {'TemperatureRounded', 'FrequencyModel', 'ChiInModel', 'ChiOutModel'};
    end
    
    methods
        fitTau(obj)
        
        function obj = DebyeData(varargin)
            obj = obj@TauData(varargin{:});
            obj.Fits = cell2table(cell(0, length(obj.FitFields)), 'VariableNames', obj.FitFields);
            obj.Errors = cell2table(cell(0, length(obj.ErrorFields)), 'VariableNames', obj.ErrorFields);
            obj.Model = cell2table(cell(0, length(obj.ModelFields)), 'VariableNames', obj.ModelFields);
        end
    end
    
    methods (Static)
       model = generalizedDebyeModel(b, x)
    end
end