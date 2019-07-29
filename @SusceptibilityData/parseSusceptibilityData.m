function parseSusceptibilityData(obj, susceptibilityData)
    toAdd = array2table([susceptibilityData.Raw{:, SQUIDDataFile.MomentFieldsRaw}], 'VariableNames', SQUIDDataFile.MomentFieldsRaw);
    
    toAdd.Moment = ((toAdd.Moment ./ susceptibilityData.Header.Moles) ...
        - (SQUIDDataFile.EicosaneXdm * susceptibilityData.Header.EicosaneMoles .* toAdd.Field) ...
        - (susceptibilityData.Header.Xdm .* toAdd.Field));
    toAdd.MomentErr = ((toAdd.MomentErr ./ susceptibilityData.Header.Moles) ...
        - (SQUIDDataFile.EicosaneXdm * susceptibilityData.Header.EicosaneMoles .* toAdd.Field) ...
        - (susceptibilityData.Header.Xdm .* toAdd.Field));
    toAdd.ChiT = toAdd.Moment ./ toAdd.Field .* toAdd.Temperature;
    toAdd.ChiTErr = toAdd.MomentErr ./ toAdd.Field .* toAdd.Temperature;

    obj.Parsed = [obj.Parsed; toAdd];
end