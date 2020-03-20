classdef SusceptibilityData < SQUIDData
    methods
        function obj = SusceptibilityData(varargin)
            obj = obj@SQUIDData(varargin{:});
            obj.Parsed = [];
            obj.parseSusceptibilityData();
        end

        plot(obj, varargin);
    end

    methods (Access = private)
        parseSusceptibilityData(obj);
    end
end