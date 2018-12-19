classdef SQUIDData < handle
% SQUIDData     A collection of Matlab functions that parse and plot data 
%               from a Quantum Design MPMS 3 SQUID magnetometer
%   
%   This package currently consists of six user classes whose names are: 
%   AcData, DcData, MagData, PlotHelper, Relaxation, and SusData
%   
%   Type `help ClassName` to get specific usage instructions for a given class 
%
%   Type `help ClassName.methodName` to get specific usage instructions for 
%   a given class method

    properties
        Filename    = []; % (string) filename
        Header      = []; % (table) header information
        Raw         = []; % (table) raw data
        Parsed      = []; % (table) parsed data
    end
    
    methods (Access = protected)
        function obj = SQUIDData(filename)
            obj.Filename = filename;
            fileID = fopen(obj.Filename, 'r');
            obj.parseFile(textscan(fileID, '%s', 50, 'Delimiter', '\n'))
            fclose(fileID);
        end 
    end
    
    methods (Access = private)
        function parseFile(obj, contents)
            for a = 1:length(contents{1})
                if strcmp('[Data]', contents{1}{a})
                    dataLine = a;
                    break;
                end
            end
            obj.parseHeader(contents, dataLine - 1);
            obj.parseData(dataLine);
        end
        
        function parseHeader(obj, contents, dataLine)
            header = [];
            for a = 1:dataLine
                if strncmp(contents{1}{a}, 'INFO', 4) && not(length(strfind(contents{1}{a}, 'APPNAME')))
                    header = [header; regexp(contents{1}{a}, ',', 'split')];
                end
            end
            if strcmp(header{2,2}, '')
                header{2,2} = 'None';
            end
            if strcmp(header{4,2}, '')
                header{4,2} = '100';
            end
            if strcmp(header{6,2}, '')
                header{6,2} = '1000';
            end
            obj.Header   = cell2table([ ...
                header(2,2) header(3,2) str2double(header(4,2)) str2double(header(5,2)) ...
                str2double(header(6,2)) str2double(header(4,2))/1000/str2double(header(6,2)) str2double(header(5,2))/1000/282.55 str2double(header(7,2)) -0.00024306], ...
                'VariableNames', {'Name', 'Description', 'Mass', 'EicosaneMass', 'MolecularWeight', 'Moles', 'EicosaneMoles', 'Xdm', 'EicosaneXdm'});
            obj.Header.Name = char(obj.Header.Name);
            obj.Header.Description = char(obj.Header.Description);
        end
        
        function parseData(obj, dataLine)
            warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
            obj.Raw = readtable(obj.Filename, 'HeaderLines', dataLine, 'CommentStyle', {'(', ')'});
            toDelete = obj.Raw.Temperature_K_ < 1.7;
            obj.Raw(toDelete, :) = [];
        end
    end
end
