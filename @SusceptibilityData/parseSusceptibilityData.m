function parseSusceptibilityData(obj)
    for a = 1:length(obj.DataFiles)
        toAdd = array2table([obj.DataFiles(a).Raw{:, SQUIDDataFile.MomentFieldsRaw}], 'VariableNames', SQUIDDataFile.MomentFieldsRaw);

        toAdd.Moment = toAdd.Moment - (SQUIDDataFile.EicosaneXdm .* obj.DataFiles(a).Header.EicosaneMoles .* toAdd.Field) - (obj.DataFiles(a).Header.Xdm .* obj.DataFiles(a).Header.Moles .* toAdd.Field);
        toAdd.MomentErr = toAdd.MomentErr - (SQUIDDataFile.EicosaneXdm .* obj.DataFiles(a).Header.EicosaneMoles .* toAdd.Field) - (obj.DataFiles(a).Header.Xdm .* obj.DataFiles(a).Header.Moles .* toAdd.Field);
        toAdd.MomentMass = toAdd.Moment ./ (obj.DataFiles(a).Header.Mass / 1000);
        toAdd.MomentMassErr = toAdd.MomentErr ./ (obj.DataFiles(a).Header.Mass / 1000);
        toAdd.MomentMoles = toAdd.Moment ./ obj.DataFiles(a).Header.Moles;
        toAdd.MomentMolesErr = toAdd.MomentErr ./ obj.DataFiles(a).Header.Moles;
        toAdd.Chi = toAdd.MomentMoles ./ toAdd.Field;
        toAdd.ChiErr = toAdd.MomentMolesErr ./ toAdd.Field;
        toAdd.ChiT = toAdd.Chi .* toAdd.Temperature;
        toAdd.ChiTErr = toAdd.ChiErr .* toAdd.Temperature;
                            
        idxs = obj.findDataBlocks(obj.DataFiles(a), 500);
        data_blocks = arrayfun(@(a) a .* ones(idxs(a + 1) - idxs(a), 1), 1:(length(idxs) - 1), 'UniformOutput', false);
        data_blocks = vertcat(data_blocks{:}, length(idxs) - 1);
        toAdd.DataBlock = data_blocks;
        
        obj.Parsed = [obj.Parsed; toAdd];
    end
end