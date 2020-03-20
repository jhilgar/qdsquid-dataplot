classdef WaveformData < DebyeData
    properties
        Spectra;
    end

    properties (Access = protected)
        WaveformFieldsParsed = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut', 'phi'};
        WaveformFieldsSpectra = {'TemperatureRounded', 'Datablock', 'Frequency', 'hsDFTM', 'hsDFTF'};
    end

    methods
        plot(obj, plot_type, varargin);

        function obj = WaveformData(varargin)
            obj = obj@DebyeData(varargin{:}); 
            obj.Parsed = cell2table(cell(0, length(obj.WaveformFieldsParsed)), 'VariableNames', obj.WaveformFieldsParsed);
            obj.Spectra = cell2table(cell(0, length(obj.WaveformFieldsSpectra)), 'VariableNames', obj.WaveformFieldsSpectra);

            for a = 1:length(obj.DataFiles)
                obj.parseWaveformData(obj.DataFiles(a));
            end
        end
    end

    methods (Access = private)
        parseWaveformData(obj, waveformData);
    end
end