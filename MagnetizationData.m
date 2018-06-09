classdef MagnetizationData < DataSet
    
    properties
        Temperatures = [];
    end
    
    methods
        function obj = MagnetizationData(filename)
            obj = obj@DataSet(filename);
            
            obj.Data.Moment              = (obj.RawData.DCMomentFreeCtr_emu_ / obj.Header.Moles) ...
                                            - (obj.Header.EicosaneXdm * obj.Header.EicosaneMoles * obj.Data.Field) ...
                                            - (obj.Header.Xdm * obj.Data.Field);
            obj.Data.EffectiveMoment     = obj.Data.Moment / 5585;
            
            toDelete = obj.Data.TemperatureRounded < 0 | obj.Data.TemperatureRounded > 250;
            obj.Data(toDelete,:) = [];
            obj.Temperatures = unique(obj.Data.TemperatureRounded);
        end
        
        function plotMagnetization(obj, varargin)
            hold on;
            for a = 1:length(obj.Temperatures)
                rows = obj.Data.TemperatureRounded == obj.Temperatures(a);
                scatter(obj.Data.Field(rows), obj.Data.EffectiveMoment(rows), 15, 'filled');
            end
        end
        
        function writePhi(obj)
            output = unique(round(obj.Data.Field, -1)) / 10000;
            for a = 1:length(obj.Temperatures)
                rows = obj.Data.TemperatureRounded == obj.Temperatures(a);
                output = [output obj.Data.EffectiveMoment(rows)];
            end
            dlmwrite(strcat(obj.Header.Name, '_mag.exp'), output, ' ');
        end
    end
end