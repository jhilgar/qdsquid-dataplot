classdef SusceptibilityData < SQUIDData
    properties (Access = protected, Constant)
        SusceptibilityFieldsParsed = {'Time', 'Temperature', 'Field', 'Moment', 'MomentErr', 'ChiT', 'ChiTErr'};
    end

    methods
        function obj = SusceptibilityData(varargin)
            obj = obj@SQUIDData(varargin{:});
            obj.Parsed = cell2table(cell(0, length(obj.SusceptibilityFieldsParsed)), 'VariableNames', obj.SusceptibilityFieldsParsed);

            for a = 1:length(obj.DataFiles)
                obj.parseSusceptibilityData(obj.DataFiles(a));
            end
        end

        function writeData(obj)
            warning('off', 'MATLAB:xlswrite:AddSheet');
            writetable(obj.Parsed, [inputname(1) '.xlsx'], 'Sheet', 1);
 
            disp(['Wrote data to ' inputname(1) '.xlsx']);
        end
    end

    methods (Access = private)
        parseSusceptibilityData(obj, susceptibilityData)
    end
end