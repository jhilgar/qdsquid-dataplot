classdef Relaxation < handle
    properties
        Data = [];
        Fits = [];
        Model = [];
    end
    
    properties (Access = protected, Constant)
        FitOpts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');
    end
    
    methods
        function obj = Relaxation(temp, tau)
            obj.Data = [temp, tau];
            obj.Data = array2table(obj.Data, 'VariableNames', {'Temperature', 'tau'}); 
        end

        function plot(obj)
            plot(1./obj.Model.Temperature, log(obj.Model.tau));
        end

        function fitRelaxation(obj, varargin)
            p = inputParser;
            validLogical = @(x) islogical(x);
            p.addParameter('orbach', 1, validLogical);
            p.addParameter('raman', 0, validLogical);
            p.addParameter('qtm', 0, validLogical);
            p.parse(varargin{:})

            obj.Fits = [];
            obj.Model = [];

            if ~(p.Results.orbach) && ~(p.Results.raman) && ~(p.Results.raman)
                disp('Compound unable to relax.')
                return;
            end

            orbachx0 = [100, 1E-9]; ramanx0 = [5E-5, 5]; qtmx0 = [1E-4];
            orbachlb = [0.2, 1E-15]; ramanlb = [1E-7, 2]; qtmlb = [1E-6];
            orbachub = [200, 200]; ramanub = [1E-1, 9]; qtmub = [1E4];

            x0 = [repmat(orbachx0, 1, p.Results.orbach), repmat(ramanx0, 1, p.Results.raman), repmat(qtmx0, 1, p.Results.qtm)];
            lb = [repmat(orbachlb, 1, p.Results.orbach), repmat(ramanlb, 1, p.Results.raman), repmat(qtmlb, 1, p.Results.qtm)];
            ub = [repmat(orbachub, 1, p.Results.orbach), repmat(ramanub, 1, p.Results.raman), repmat(qtmub, 1, p.Results.qtm)];

            opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                                  'FunctionTolerance', 1e-30, 'OptimalityTolerance', 1e-30, 'StepTolerance', 1e-30, ...
                                  'ObjectiveLimit', 1e-30, 'Display', 'off', 'ConstraintTolerance', 1E-30);
            gs = GlobalSearch('MaxTime', 30, 'Display', 'off', 'NumTrialPoints', 3000, 'NumStageOnePoints', 600);
            problem = createOptimProblem('fmincon', 'x0', x0, 'objective', @(b) Relaxation.objective(obj.Data.Temperature, log(1./obj.Data.tau), p.Results.orbach, p.Results.raman, p.Results.qtm, b), ...
                                     'lb', lb, 'ub', ub, 'options', opts);
            [obj.Fits, ~, ~, ~, ~] = gs.run(problem);

            xmodel = logspace(log10(min(obj.Data.Temperature)), log10(max(obj.Data.Temperature + 3)), 100)';
            ymodel = Relaxation.model(xmodel, p.Results.orbach, p.Results.raman, p.Results.qtm, obj.Fits);
            varnames = {repmat({'Ueff', 'tau_0'}, 1, p.Results.orbach), repmat({'C', 'n'}, 1, p.Results.raman), repmat({'qtm'}, 1, p.Results.qtm)}
            obj.Fits = array2table(obj.Fits, 'VariableNames', [varnames{:}]);
            obj.Model = [xmodel, 1./ymodel];
            obj.Model = array2table(obj.Model, 'VariableNames', {'Temperature', 'tau'})
        end
    end

    methods (Static)
        function output = objective(xdata, ydata, orbach, raman, qtm, b)
            ycalc = log(Relaxation.model(xdata, orbach, raman, qtm, b));

            output = sum((ydata - ycalc).^2);
        end

        function output = model(xdata, orbach, raman, qtm, b)
            ycalc = 0;

            if (orbach)
                ycalc = ycalc + (1 / b(2)).*exp(-b(1) ./ (0.695.*xdata));
            end
            if (raman)
                ycalc = ycalc + b(1 + 2*orbach).*xdata.^(2 + 2*orbach);
            end
            if (qtm)
                ycalc = ycalc + (1 / b(1 + 2*orbach + 2*raman));
            end

            output = ycalc;
        end
    end
end