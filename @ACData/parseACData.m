function parseACData(obj, acData)
    toAdd = array2table([acData.Raw{:, SQUIDDataFile.ACFieldsRaw}], 'VariableNames', obj.ACFieldsParsed);
    toAdd.TemperatureRounded = round(toAdd.TemperatureRounded / 0.05) * 0.05;
    toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} = toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} ./ acData.Header.Moles;
    obj.Parsed = [obj.Parsed; toAdd];

    obj.Parsed = sortrows(obj.Parsed, {'TemperatureRounded', 'Frequency'});
end