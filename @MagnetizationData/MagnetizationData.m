classdef MagnetizationData < SQUIDData
    methods
        function obj = MagnetizationData(varargin)
            obj = obj@SQUIDData(varargin{:});
            obj.Parsed = [];
            obj.parseMagnetizationData();
        end

        plot(obj, varargin);
    end

    methods (Access = private)
        parseMagnetizationData(obj);
    end
end