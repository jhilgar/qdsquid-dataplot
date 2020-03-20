classdef ACData < DebyeData
    methods
        function obj = ACData(varargin)
            obj = obj@DebyeData(varargin{:}); 
            obj.Parsed = [];
            obj.parseACData();
        end
    end

    methods (Access = private)
        parseACData(obj);
    end
end