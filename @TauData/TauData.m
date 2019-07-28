classdef TauData < SQUIDData
    properties
        FitType;
        Fits;
        Errors;
        Model;
    end
    
    methods (Abstract)
        fitTau(obj);
    end
    
    methods
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

    methods (Access = protected)
        idxs = findDataBlocks(obj, data, time)
    end
end