function fitTau(obj)
    obj.FitType = 'GeneralizedDebye';
    temps = unique(obj.Parsed.TemperatureRounded);

    disp(['Fitting DebyeData with ' obj.FitType ' fit type.']);
    for a = 1:length(temps)
        rows = obj.Parsed.TemperatureRounded == temps(a);

        [obj.x0, ~, resid, ~, ~, ~, J] = ...
            lsqcurvefit(@obj.generalizedDebyeModel, obj.x0, obj.Parsed.Frequency(rows), [obj.Parsed.ChiIn(rows), obj.Parsed.ChiOut(rows)], obj.lb, obj.ub, obj.FitOpts);
        y = nlparci(obj.x0, resid, 'Jacobian', J);
        toAdd = array2table([temps(a), obj.x0], 'VariableNames', obj.FitFields);
        obj.Fits = [obj.Fits; toAdd];
        frequencies = linspace(min(obj.Parsed.Frequency(rows)), max(obj.Parsed.Frequency(rows)), 100);
        model = obj.generalizedDebyeModel(obj.x0, frequencies);
        toAdd = array2table([temps(a)*ones(size(model, 1), 1) frequencies' model], 'VariableNames', obj.ModelFields); 
        obj.Model = [obj.Model; toAdd];
        toAdd = array2table([temps(a), y(1, :), y(2, :), y(3, :), y(4, :)], 'VariableNames', obj.ErrorFields);
        obj.Errors = [obj.Errors; toAdd]; 
    end
end