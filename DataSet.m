classdef DataSet < handle
    
    properties
        Filename    = [];
        Header      = [];
        RawData     = [];
        Data        = [];
    end
    
    methods
        function obj = DataSet(filename)
            obj.Filename = filename;
            fileID = fopen(obj.Filename, 'r');
            obj.parseFile(textscan(fileID, '%s', 50, 'Delimiter', '\n'))
            fclose(fileID);
            obj.setDefaults();
        end
    end
    
    methods (Access = private)
        function setDefaults(obj)
            set(groot,'defaultLineLineWidth',1);
            set(groot,'defaultAxesLineWidth',1.5);
            set(groot,'defaultLineMarkerSize',6);
            set(groot,'defaultScatterSizeData',10);
            set(groot,'defaultScatterLineWidth',1.5);
            set(groot,'defaultAxesFontWeight','bold');
            set(groot,'defaultAxesFontSize',15);
            set(groot,'defaultScatterSizeData',15);
            set(groot,'defaultAxesBox','on');
            set(groot,'defaultAxesTickLength', [0.0175 0.01]);
            set(groot,'defaultFigurePaperPosition', [0 0 8 8]);
            set(groot,'defaultScatterSizeData',15);
        end
        
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
           obj.RawData = readtable(obj.Filename, 'HeaderLines', dataLine, 'CommentStyle', {'(', ')'});
           
           obj.Data                     = table(obj.RawData.Temperature_K_, 'VariableNames', {'Temperature'});
           obj.Data.TemperatureRounded  = round(obj.Data.Temperature,1);
           obj.Data.Field               = obj.RawData.MagneticField_Oe_;
        end
    end
    
end
