function fitTau2(obj, varargin)
    p = inputParser;
    validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (mod(x, 1) == 0) && (x >= 0);
    p.addParameter('E', 1, validScalarPosInt);
    p.addParameter('SE', 0, validScalarPosInt);
    p.parse(varargin{:});

    obj.nE = p.Results.E;
    obj.nSE = p.Results.SE;
    obj.Fits = table;
    obj.Model = table;
    obj.Errors = table;

    ex0 = [1E2, 1/(obj.nE + obj.nSE)];
    elb = [1, 0];
    eub = [1E5, 1];

    sex0 = [1E2, 0.9, 1/(obj.nE + obj.nSE)];
    selb = [1, 1E-2, 0];
    seub = [1E5, 1, 1];

    mfx0 = [0];
    mflb = [-1E2];
    mfub = [1E2];

    x0 = [repmat(ex0, 1, obj.nE), repmat(sex0, 1, obj.nSE), mfx0];
    lb = [repmat(elb, 1, obj.nE), repmat(selb, 1, obj.nSE), mflb];
    ub = [repmat(eub, 1, obj.nE), repmat(seub, 1, obj.nSE), mfub];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                                  'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10, ...
                                  'ObjectiveLimit', 1e-10, 'Display', 'off', 'ConstraintTolerance', 1E-10);
    gs = GlobalSearch('MaxTime', 30, 'Display', 'off');

    temps = unique(obj.Parsed.TemperatureRounded);
    %xmodel = logspace(log10(min(obj.Parsed.Frequency)), log10(max(obj.Parsed.Frequency)), 100)';

    for a = 1:length(temps)
        disp(['Fitting ' num2str(temps(a)) 'K data.']);

        rows = obj.Parsed.TemperatureRounded == temps(a);
        problem = createOptimProblem('fmincon', 'x0', x0, ...
                                     'objective', @(b) objective(obj.Parsed.Time(rows), obj.Parsed.Moment(rows), obj.nE, obj.nSE, b, max(obj.Parsed.Moment(rows))), ...
                                     'lb', lb, 'ub', ub, 'options', opts); % , 'nonlcon', @(b) constraints(p.Results.CC, p.Results.HN, b)
        [x0, ~, ~, ~, ~] = gs.run(problem)
    end
end

function output = objective(xdata, ydata, e, se, b, m0)
    ycalc = ExponentialData.model(xdata, e, se, b, m0);

    output = sum((log10(ydata) - log10(ycalc)).^2);
end

function [c, ceq] = constraints(cc, hn, b)
    c = [];
    ceq = [];
    for a = cc:(cc + hn - 1)
        % todo 
    end
end
