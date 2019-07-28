classdef ACData < DebyeData
    properties (Access = protected)
        ACFieldsParsed = {'Time', 'TemperatureRounded', 'Field', 'Frequency', 'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'};
    end

    methods
        function obj = ACData(varargin)
            obj = obj@DebyeData(varargin{:}); 
            obj.Parsed = cell2table(cell(0, length(obj.ACFieldsParsed)), 'VariableNames', obj.ACFieldsParsed);

            for a = 1:length(obj.DataFiles)
                obj.parseACData(obj.DataFiles(a));
            end

            obj.fitTau();
        end
    end

    methods (Access = private)
        parseACData(obj, acData)
    end
end