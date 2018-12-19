classdef MagData < SQUIDData
    properties
        Temperatures = [];
    end
    
    methods
        function obj = MagData(filename)
            obj = obj@SQUIDData(filename);
            
            obj.Parsed = table(obj.Raw.Temperature_K_, 'VariableNames', {'Temperature'});
            obj.Parsed.Field = obj.Raw.MagneticField_Oe_;
            obj.Parsed.Moment             = (obj.Raw.DCMomentFreeCtr_emu_ ./ obj.Header.Moles) ...
                                            - (obj.Header.EicosaneXdm * obj.Header.EicosaneMoles .* obj.Parsed.Field) ...
                                            - (obj.Header.Xdm .* obj.Parsed.Field);
            obj.Parsed.EffectiveMoment    = obj.Parsed.Moment / 5585;
            
            obj.Temperatures = unique(obj.Parsed.TemperatureRounded);
        end
        
        function plotMagnetization(obj)
            PlotHelper.setDefaults();
            for a = length(obj.Temperatures):-1:1
                rows = (obj.Parsed.TemperatureRounded == obj.Temperatures(a)) & (obj.Parsed.TemperatureRounded < 301);
                plot(obj.Parsed.Field(rows) ./ 10000, obj.Parsed.EffectiveMoment(rows), 'Color', PlotHelper.dataColor(obj.Temperatures(a)), 'LineWidth', 1.5);
            end
            xlabel('H (T)'); ylabel('\mu_B (emu mol^{-1})');
        end
        
        function writePhi(obj, filename)
            output = unique(round(obj.Parsed.Field, -1)) / 10000;
            for a = 1:length(obj.Temperatures)
                rows = obj.Parsed.TemperatureRounded == obj.Temperatures(a);
                output = [output obj.Parsed.EffectiveMoment(rows)];
            end
            dlmwrite(strcat(filename, '_mag.exp'), output, ' ');
        end
    end
end