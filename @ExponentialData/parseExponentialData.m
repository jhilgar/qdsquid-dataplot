function parseExponentialData(obj, exponentialData)
    idxs = obj.findDataBlocks(exponentialData, 100);

    for a = 1:(length(idxs) - 1)
        start = idxs(a);
        stop = idxs(a + 1) - 1;
        exponential = exponentialData.Raw(start:stop, :);

        newExponential = array2table([exponential{:, {'Time', 'Temperature', 'Moment'}}], 'VariableNames', obj.ExponentialFieldsParsed);
        newExponential.TemperatureRounded = round(newExponential.TemperatureRounded / 0.05) * 0.05;
        newExponential.Time = newExponential.Time - newExponential.Time(1);
        newExponential.Moment = newExponential.Moment / exponentialData.Header.Moles;
        obj.Parsed = [obj.Parsed; newExponential];
    end

    obj.Parsed = sortrows(obj.Parsed, {'TemperatureRounded'});
end