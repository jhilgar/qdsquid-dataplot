classdef WaveformData < DebyeData
    properties
        Spectra;
    end

    properties (Access = protected)
        WaveformFieldsParsed = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut', 'phi'};
        WaveformFieldsSpectra = {'TemperatureRounded', 'Frequency', 'hsDFTM', 'hsDFTF'};
    end

    methods
        function obj = WaveformData(varargin)
            obj = obj@DebyeData(varargin{:}); 
            obj.Parsed = cell2table(cell(0, length(obj.WaveformFieldsParsed)), 'VariableNames', obj.WaveformFieldsParsed);
            obj.Spectra = cell2table(cell(0, length(obj.WaveformFieldsSpectra)), 'VariableNames', obj.WaveformFieldsSpectra);

            for a = 1:length(obj.DataFiles)
                obj.parseWaveformData(obj.DataFiles(a));
            end

            obj.fitTau();
        end
    end

    methods (Access = private)
        parseWaveformData(obj, waveformData)
    end
end