classdef TauData < SQUIDData
    properties
        Fits = cell2table(cell(0, 2), 'VariableNames', {'TemperatureRounded', 'tau'});
        Errors = table;
        Model = cell2table(cell(0, 4), 'VariableNames', {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'});
    end
    
    methods (Abstract)
        fitTau(obj);
    end
    
    methods
        plot(obj, plot_type, varargin);

        function obj = TauData(varargin) 
            obj = obj@SQUIDData(varargin{:});
        end
        

        function writeData(obj)
            warning('off', 'MATLAB:xlswrite:AddSheet');
            writetable(obj.Parsed, [inputname(1) '.xlsx'], 'Sheet', 1);
            writetable(obj.Fits, [inputname(1) '.xlsx'], 'Sheet', 2);
            writetable(obj.Errors, [inputname(1) '.xlsx'], 'Sheet', 3);
            writetable(obj.Model, [inputname(1) '.xlsx'], 'Sheet', 4);
            
            disp(['Wrote data to ' inputname(1) '.xlsx']);
        end
    end
end