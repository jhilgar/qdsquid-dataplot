function fitTau(obj, fitType)
    obj.FitType = []; obj.Fits = []; obj.Errors = []; obj.Model = [];
    switch fitType
        case 'bi'
            fitIdx = 1;
            obj.FitType = 'BiExponential';
        case 'stretched'
            fitIdx = 2;
            obj.FitType = 'StretchedExponential';
        otherwise
            disp('Unrecognized fit type (bi and stretched supported).');
            return;
    end

    disp(['Fitting ExponentialData with ' obj.FitType ' fit type.']);
    temps = unique(obj.Parsed.TemperatureRounded);
    for a = 1:length(temps)
        rows = obj.Parsed.TemperatureRounded == temps(a);

        [obj.ExponentialBounds{fitIdx}(1, :), ~, resid, ~, ~, ~, J] = ...
            lsqcurvefit(@(b, x) obj.ExponentialFitFunctions{fitIdx}(b, x, max(obj.Parsed.Moment(rows))), obj.ExponentialBounds{fitIdx}(1, :), obj.Parsed.Time(rows), obj.Parsed.Moment(rows), obj.ExponentialBounds{fitIdx}(2, :), obj.ExponentialBounds{fitIdx}(3, :), obj.FitOpts);
        y = nlparci(obj.ExponentialBounds{fitIdx}(1, :), resid, 'Jacobian', J);
        toAdd = array2table([temps(a), obj.ExponentialBounds{fitIdx}(1, :)], 'VariableNames', obj.ExponentialFits{fitIdx});
        obj.Fits = [obj.Fits; toAdd];
        model = obj.ExponentialFitFunctions{fitIdx}(obj.ExponentialBounds{fitIdx}(1, :), obj.Parsed.Time(rows), max(obj.Parsed.Moment(rows)));
        toAdd = array2table([obj.Parsed.Time(rows) temps(a)*ones(size(obj.Parsed.Time(rows), 1), 1) model], 'VariableNames', obj.ModelFields);
        obj.Model = [obj.Model; toAdd];
        toAdd = array2table([temps(a), reshape(y.', 1, [])], 'VariableNames', obj.ExponentialErrors{fitIdx});
        obj.Errors = [obj.Errors; toAdd]; 
    end
end