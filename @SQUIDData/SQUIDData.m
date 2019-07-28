classdef SQUIDData < handle
    properties
        DataFiles = [];
        Parsed = [];
    end
    
    methods
        function obj = SQUIDData(varargin)
            if isempty(varargin)
               disp('SQUIDData constructor called with no arguments, reading all .dat files in current directory.') 
               varargin = dir('*.dat');
               varargin = {varargin.name};
            end

            for a = 1:length(varargin)
               obj.DataFiles = [obj.DataFiles; SQUIDDataFile(varargin{a})]; 
            end
        end
    end
end