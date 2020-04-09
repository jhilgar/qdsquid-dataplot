function fitTau(obj, varargin)
    p = inputParser;
    validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (mod(x, 1) == 0) && (x >= 0);
    p.addParameter('CC', 1, validScalarPosInt);
    p.addParameter('HN', 0, validScalarPosInt);
    p.parse(varargin{:});

    obj.nCC = p.Results.CC;
    obj.nHN = p.Results.HN;
    obj.Fits = table;
    obj.Model = table;
    obj.Errors = table;

    ccx0 = [1/(2*pi*((max(obj.Parsed.Frequency) + min(obj.Parsed.Frequency))/2)), 0.3, 1];
    cclb = [1/(1.1*2*pi*max(obj.Parsed.Frequency)), 0, 0.2];
    ccub = [1/(0.9*2*pi*min(obj.Parsed.Frequency)), 0.5, 15];

    hnx0 = [1/(2*pi*((max(obj.Parsed.Frequency) + min(obj.Parsed.Frequency))/2)), 0.9, 1, 5];
    hnlb = [1/(2*pi*max(obj.Parsed.Frequency)*1.05), 0.01, 0.01, 1E-1];
    hnub = [1/(2*pi*min(obj.Parsed.Frequency)*0.95), 1, 1, 15];

    chiInfx0 = [0];
    chiInflb = [0.01];
    chiInfub = [max(obj.Parsed.ChiOut)];

    x0 = [repmat(ccx0, 1, obj.nCC), repmat(hnx0, 1, obj.nHN), chiInfx0];
    lb = [repmat(cclb, 1, obj.nCC), repmat(hnlb, 1, obj.nHN), chiInflb];
    ub = [repmat(ccub, 1, obj.nCC), repmat(hnub, 1, obj.nHN), chiInfub];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                                  'FunctionTolerance', 1e-23, 'OptimalityTolerance', 1e-23, 'StepTolerance', 1e-23, ...
                                  'ObjectiveLimit', 1e-23, 'Display', 'off', 'ConstraintTolerance', 1E-23);
    opts2 = optimoptions('lsqcurvefit', 'Algorithm', 'Levenberg-Marquardt', ...
                                  'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10, ...
                                  'Display', 'off');
    gs = GlobalSearch('MaxTime', 30, 'Display', 'off');

    temps = unique(obj.Parsed.TemperatureRounded);
    %xmodel = logspace(log10(min(obj.Parsed.Frequency)), log10(max(obj.Parsed.Frequency)), 100)';

    cc_vars = {'cc_tau_', 'cc_alpha_', 'cc_chi_t_'};
    cc_vars = cellfun(@(x, y) [x num2str(y)], repmat(cc_vars, 1, obj.nCC), num2cell(ceil((1:3*obj.nCC)/3)), 'UniformOutput', false);
    cc_error_vars = {'cc_tau_ci_neg_', 'cc_tau_ci_pos_', 'cc_alpha_ci_neg_', 'cc_alpha_ci_pos_', 'cc_chi_t_ci_neg_', 'cc_chi_t_ci_pos_'};
    cc_error_vars = cellfun(@(x, y) [x num2str(y)], repmat(cc_error_vars, 1, obj.nCC), num2cell(ceil((1:6*obj.nCC)/6)), 'UniformOutput', false);
    hn_vars = {'hn_tau_', 'hn_alpha_', 'hn_beta_', 'hn_chi_t_'};
    hn_vars = cellfun(@(x, y) [x num2str(y)], repmat(hn_vars, 1, obj.nHN), num2cell(ceil((1:4*obj.nHN)/4)), 'UniformOutput', false);
    hn_error_vars = {'hn_tau_ci_neg_', 'hn_tau_ci_pos_', 'hn_alpha_ci_neg_', 'hn_alpha_ci_pos_', 'hn_beta_ci_neg_', 'hn_beta_ci_pos_', 'hn_chi_t_ci_neg_', 'hn_chi_t_ci_pos_'};
    hn_error_vars = cellfun(@(x, y) [x num2str(y)], repmat(hn_error_vars, 1, obj.nHN), num2cell(ceil((1:8*obj.nHN)/8)), 'UniformOutput', false);
    fit_vars = {'TemperatureRounded', cc_vars, hn_vars, 'chi_s'};
    error_vars = {'TemperatureRounded', cc_error_vars, hn_error_vars, 'chi_s_ci_neg', 'chi_s_ci_pos'};
    model_vars = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'};

    for a = 1:length(temps)
        disp(['Fitting ' num2str(temps(a)) 'K data.']);
        rows = obj.Parsed.TemperatureRounded == temps(a);
        xmodel = logspace(log10(min(obj.Parsed.Frequency(rows))), log10(max(obj.Parsed.Frequency(rows))), 100)';
        
        problem = createOptimProblem('fmincon', 'x0', x0, ...
                                     'objective', @(b) objective(obj.Parsed.Frequency(rows), [obj.Parsed.ChiIn(rows), obj.Parsed.ChiOut(rows)], p.Results.CC, p.Results.HN, b), ...
                                     'lb', lb, 'ub', ub, 'options', opts); % , 'nonlcon', @(b) constraints(p.Results.CC, p.Results.HN, b)
        [x0, ~, ~, ~, ~] = gs.run(problem);
        [x02, ~, residual, ~, ~, ~, jacobian] = lsqcurvefit(@(b, xdata) modelWrapper(xdata, p.Results.CC, p.Results.HN, b), x0, obj.Parsed.Frequency(rows), [obj.Parsed.ChiIn(rows), obj.Parsed.ChiOut(rows)], [], [], opts2);
        ci = nlparci(x02, residual, 'Jacobian', jacobian);

        cc_entries = [];
        cc_errors = [];
        if obj.nCC > 0
            cc_entries = x0(1:3*obj.nCC);
            cc_errors = ci(1:3*obj.nCC,:);
            if obj.nCC == 1
                cc_errors = [cc_errors(:,1), cc_errors(:,2)].';
                cc_errors = cc_errors(:)';
            else
                [~, I] = sort(cc_entries(1:3:3*obj.nCC));
                J = cell2mat(arrayfun(@(x) 3*(x-1)+(1:3), I, 'UniformOutput', false));
                cc_entries = cc_entries(J);
                cc_errors = [cc_errors(J',1), cc_errors(J',2)].';
                cc_errors = cc_errors(:)';
            end
        end
        hn_entries = [];
        hn_errors = [];
        if obj.nHN > 0
            hn_entries = x0(obj.nCC*3+(1:4*obj.nHN));
            hn_errors = ci(obj.nCC*3+(1:4*obj.nHN),:);
            if obj.nHN == 1
                hn_errors = [hn_errors(:,1), hn_errors(:,2)].';
                hn_errors = hn_errors(:)';
            else
                [~, I] = sort(hn_entries(1:4:4*obj.nHN));
                J = cell2mat(arrayfun(@(x) 4*(x-1)+(1:4), I, 'UniformOutput', false));
                hn_entries = hn_entries(J);
                hn_errors = [hn_errors(J',1), hn_errors(J',2)].';
                hn_errors = hn_errors(:)';
            end
        end
        x0 = [cc_entries, hn_entries, x0(end)];
        new_errors = array2table([temps(a), cc_errors, hn_errors, ci(end,1), ci(end,2)], 'VariableNames', [error_vars{:}]);
        new_fits = array2table([temps(a), x0], 'VariableNames', [fit_vars{:}]);
        ymodel = DebyeData.model(xmodel, obj.nCC, obj.nHN, x0);
        new_model = array2table([temps(a).*ones(length(xmodel), 1), xmodel, real(ymodel), -imag(ymodel)], 'VariableNames', model_vars);

        obj.Fits = [obj.Fits; new_fits];
        obj.Model = [obj.Model; new_model];
        obj.Errors = [obj.Errors; new_errors];
    end
end

% the model function that we minimize with GlobalSearch
function output = objective(xdata, ydata, cc, hn, b)
    ycalc = DebyeData.model(xdata, cc, hn, b);
    yreal = real(ycalc);
    yimag = -imag(ycalc);

    output = sum((ydata(:, 1) - yreal).^2) + sum((ydata(:, 2) - yimag).^2);
end

% this type of function definition is required for confidence interval
% calculation, apparently
function output = modelWrapper(xdata, cc, hn, b)
    ycalc = DebyeData.model(xdata, cc, hn, b);
    yreal = real(ycalc);
    yimag = -imag(ycalc);

    output(:, 1) = yreal;
    output(:, 2) = yimag;
end

% some papers put constraints on alpha and beta when using the HN function,
% wikipedia makes no mention of it
function [c, ceq] = constraints(cc, hn, b)
    c = [];
    ceq = [];
    for a = cc:(cc + hn - 1)
        % todo 
    end
end
