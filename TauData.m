classdef TauData < SQUIDData
    properties
        Fits;               % (table) data fits
        TempRange = NaN;    % (1x2 vector) temperature range to include for fitting
    end
    
    methods (Abstract)
        fitTau(obj);
        parseTauData(obj, tempRange);
        plotArrhenius(obj);
        setTempRange(obj, tempRange);
    end
end