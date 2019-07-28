classdef MagnetizationData < SQUIDData
    properties (Access = protected, Constant)
        MagnetizationFieldsParsed = {'Time', 'TemperatureRounded', 'Field', 'Moment', 'MomentErr'};
    end

    methods
        function obj = MagnetizationData(varargin)
            obj = obj@SQUIDData(varargin{:});
            obj.Parsed = cell2table(cell(0, length(obj.MagnetizationFieldsParsed)), 'VariableNames', obj.MagnetizationFieldsParsed);
            
            for a = 1:length(obj.DataFiles)
                obj.parseMagnetizationData(obj.DataFiles(a));
            end
        end

        function writeData(obj)
            warning('off', 'MATLAB:xlswrite:AddSheet');
            writetable(obj.Parsed, [inputname(1) '.xlsx'], 'Sheet', 1);
 
            disp(['Wrote data to ' inputname(1) '.xlsx']);
        end
    end

    methods (Access = private)
        parseMagnetizationData(obj, magnetizationData)
    end
end