classdef MagnetizationData < DataSet
    
    properties
        Temperatures = [];
    end
    
    methods
        function obj = MagnetizationData(filename)
            obj = obj@DataSet(filename);
            
            obj.Temperatures = unique(obj.Data.TemperatureRounded);
            
            obj.Data.Moment              = (obj.RawData.DCMomentFreeCtr_emu_ / obj.Header.Moles) ...
                                            - (obj.Header.EicosaneXdm * obj.Header.EicosaneMoles * obj.Data.Field) ...
                                            - (obj.Header.Xdm * obj.Data.Field);
            obj.Data.EffectiveMoment     = obj.Data.Moment / 5585;
        end
        
        function plotMagnetization(obj, varargin)
            figure;
            plot(obj.Data.Field, obj.Data.EffectiveMoment);
        end
    end
end