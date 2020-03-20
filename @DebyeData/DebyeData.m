classdef DebyeData < TauData
    methods
        fitTau(obj, varargin);
        
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