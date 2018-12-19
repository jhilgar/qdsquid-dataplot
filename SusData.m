classdef SusData < SQUIDData
    properties
        Fields = [];
    end
    
    methods
        function obj = SusData(filename)
            obj = obj@SQUIDData(filename);
            
            obj.Parsed = table(obj.Raw.Temperature_K_, 'VariableNames', {'Temperature'});
            obj.Parsed.Field = obj.Raw.MagneticField_Oe_;
            obj.Parsed.Moment             = (obj.Raw.DCMomentFreeCtr_emu_ ./ obj.Header.Moles) ...
                                            - (obj.Header.EicosaneXdm * obj.Header.EicosaneMoles .* obj.Parsed.Field) ...
                                            - (obj.Header.Xdm .* obj.Parsed.Field);
            obj.Parsed.EffectiveMoment    = obj.Parsed.Moment / 5585;
            obj.Parsed.Chi                = obj.Parsed.Moment ./ obj.Parsed.Field;
            obj.Parsed.ChiT               = obj.Parsed.Chi .* obj.Parsed.Temperature;
            
            obj.Fields = unique(obj.Parsed.Field);  
        end
        
        function plotChiT(obj)
            PlotHelper.setDefaults();
            for a = 1:length(obj.Fields)
                rows = obj.Parsed.Field == obj.Fields(a);
                scatter(obj.Parsed.Temperature(rows), obj.Parsed.ChiT(rows), 25, PlotHelper.dataColor(obj.Parsed.Temperature(rows)), 'filled');
            end
            xlabel('T (K)'); ylabel('\chiT (emu mol^{-1} K^{-1})');
        end
        
        function plotMoment(obj)
            PlotHelper.setDefaults();
            for a = 1:length(obj.Fields)
                rows = obj.Parsed.Field == obj.Fields(a);
                plot(obj.Parsed.Temperature(rows), obj.Parsed.Moment(rows));
            end
            xlabel('T (K)'); ylabel('Moment (emu mol^{-1})');
        end
        
        function writePhi(obj, filename)
            dlmwrite(strcat(filename, '_sus.exp'), obj.Parsed{:,{'Temperature', 'ChiT'}}, ' ');
        end
    end
end