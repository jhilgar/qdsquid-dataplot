classdef SusceptibilityData < DataSet
   
    properties
        Fields = [];
    end
    
    methods
        function obj = SusceptibilityData(filename)
            obj = obj@DataSet(filename);
            
            obj.Fields = unique(obj.Data.Field); 
                                        
            obj.Data.Moment             = (obj.RawData.DCMomentFreeCtr_emu_ ./ obj.Header.Moles) ...
                                            - (obj.Header.EicosaneXdm * obj.Header.EicosaneMoles .* obj.Data.Field) ...
                                            - (obj.Header.Xdm .* obj.Data.Field);
            obj.Data.Chi                = obj.Data.Moment ./ obj.Data.Field;
            obj.Data.ChiT               = obj.Data.Chi .* obj.Data.Temperature;
            obj.Data.EffectiveMoment    = obj.Data.Moment / 5585;
            
        end
        
        function plotChiT(obj, varargin)
            plot(obj.Data.Temperature, obj.Data.ChiT, varargin{:});
        end
        
        function plotMoment(obj, varargin)
            plot(obj.Data.Temperature, obj.Data.Moment, varargin{:}); 
        end
        
        function writePhi(obj)
            dlmwrite(strcat(obj.Header.Name, '_sus.exp'), obj.Data{:,{'Temperature', 'ChiT'}}, ' ');
        end
    end
    
end