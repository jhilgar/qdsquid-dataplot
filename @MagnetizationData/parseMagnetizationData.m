function parseMagnetizationData(obj)
    for a = 1:length(obj.DataFiles)
        toAdd = array2table([obj.DataFiles(a).Raw{:, SQUIDDataFile.MomentFieldsRaw}], 'VariableNames', SQUIDDataFile.MomentFieldsRaw);
        
        toAdd.TemperatureRounded = round(toAdd.Temperature / 0.5) * 0.5;
        toAdd.Moment = toAdd.Moment - (SQUIDDataFile.EicosaneXdm .* obj.DataFiles(a).Header.EicosaneMoles .* toAdd.Field) - (obj.DataFiles(a).Header.Xdm .* obj.DataFiles(a).Header.Moles .* toAdd.Field);
        toAdd.MomentErr = toAdd.MomentErr - (SQUIDDataFile.EicosaneXdm .* obj.DataFiles(a).Header.EicosaneMoles .* toAdd.Field) - (obj.DataFiles(a).Header.Xdm .* obj.DataFiles(a).Header.Moles .* toAdd.Field);
        toAdd.MomentMass = toAdd.Moment ./ (obj.DataFiles(a).Header.Mass / 1000);
        toAdd.MomentMassErr = toAdd.MomentErr ./ (obj.DataFiles(a).Header.Mass / 1000);
        toAdd.MomentMoles = toAdd.Moment ./ obj.DataFiles(a).Header.Moles;
        toAdd.MomentMolesErr = toAdd.MomentErr ./ obj.DataFiles(a).Header.Moles;
        toAdd.MomentEff = toAdd.MomentMoles ./ 5585;
        toAdd.MomentEffErr = toAdd.MomentMolesErr ./ 5585;
        
        obj.Parsed = [obj.Parsed; toAdd];
    end
    
    reorder_idxs = [1:2, 6, 3:5, 7:width(obj.Parsed)];
    obj.Parsed = obj.Parsed(:, reorder_idxs);
end