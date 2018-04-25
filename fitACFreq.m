function allOut = fitACFreq(allIn, numTemps)

    fitsOut = zeros(length(allIn{3}), 4, 3);
    
    x0 = [1e-4 1e-1 1e-3 1e-3];
    lb = [-1, -1, 1e-7, 1e-7];
    ub = [40, 40, 1, 1];
    
    for a = 1:(length(allIn{3}))
        rows = allIn{2}.TemperatureRounded == allIn{3}(a);
        opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'SpecifyObjectiveGradient', false, ...
            'FunctionTolerance', 1e-22, 'OptimalityTolerance', 1e-20, 'StepTolerance', 1e-10, 'MaxFunctionEvaluations', 50000, 'MaxIterations', 50000);
        [fitsOut(a,1:4,1), resnorm, resid, exitflag, output, lambda, J] = ...
            lsqcurvefit(@(b, x) fitFunctions(b, x), x0, allIn{2}.AcFreqRad(rows), [allIn{2}.ChiPrime(rows) allIn{2}.ChiDoublePrime(rows)], lb, ub, opts);
        fitsOut(a, 1:4, 2:3) = nlparci(fitsOut(a, 1:4, 1), resid, 'Jacobian', J);
        x0 = fitsOut(a, 1:4, 1);
    end

    arr = polyfit(1./allIn{3}(end - numTemps + 1:end), log(fitsOut(end - numTemps + 1:end,4,1)), 1);
    allOut = {allIn{1} allIn{2} allIn{3} allIn{4} arr fitsOut};
    assignin('base', allOut{1}.Name{1}, allOut);
    
end