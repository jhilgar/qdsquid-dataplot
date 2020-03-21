classdef TauData < SQUIDData
    properties
        Fits   = table;
        Errors = table;
        Model  = cell2table(cell(0, 4), 'VariableNames', {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'});
    end
    
    methods (Abstract)
        fitTau(obj);
    end
    
    methods
        plot(obj, plot_type, varargin);

        function obj = TauData(varargin) 
            obj = obj@SQUIDData(varargin{:});
        end
        
        function writeData(obj, filename)
            obj.writeData@SQUIDData(filename);
            writetable(obj.Fits, [filename '.xlsx'], 'Sheet', 2);
            writetable(obj.Errors, [filename '.xlsx'], 'Sheet', 3);
            writetable(obj.Model, [filename '.xlsx'], 'Sheet', 4);
            
            disp(['Wrote data to ' filename '.xlsx']);
        end
    end
end