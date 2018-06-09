classdef AcData < DataSet
   
    properties
        Temperatures        = [];
        DebyeFits           = [];
        RelaxationFits      = [];
    end
    
    methods
        function obj = AcData(filename)
            obj = obj@DataSet(filename);
            
            obj.Data.Frequency  = obj.RawData.ACFrequency_Hz_;
            obj.Data.ChiIn      = obj.RawData.ACX__emu_Oe_ / obj.Header.Moles;
            obj.Data.ChiOut     = obj.RawData.ACX___emu_Oe_ / obj.Header.Moles;
            
            toDelete = obj.Data.ChiIn < -1e-7 | obj.Data.ChiOut < -1e-7 | obj.Data.TemperatureRounded < 0 | obj.Data.TemperatureRounded > 8;
            obj.Data(toDelete,:) = [];
            
            obj.Temperatures = unique(obj.Data.TemperatureRounded);
            
            obj.fitDebye();
            obj.fitRelaxation();
        end
        
        function plotInPhase(obj, varargin)
            hold on;
            for a = 1:length(obj.Temperatures)
                rows = obj.Data.TemperatureRounded == obj.Temperatures(a);
                scatter(obj.Data.Frequency(rows), obj.Data.ChiIn(rows), 10, 'filled', varargin{:});
                plot(obj.Data.Frequency(rows),subsref(obj.debyeFunctions(obj.DebyeFits{a, {'Xs', 'Xd', 'alpha', 'tau'}}, obj.Data.Frequency(rows)*2*pi), struct('type', '()', 'subs', {{':', 1}})),'Color',[0 0 0]);
                xlabel('Frequency (Hz)'); ylabel('\chi\prime (emu mol^{-1})');
                set(gca, 'XScale', 'log', 'Box', 'on');
            end
            xlim([0.8 1250]);
            ylim([-0.2 12]);
        end
        
        function plotOutOfPhase(obj, varargin)
            hold on;
            for a = 1:length(obj.Temperatures)
                rows = obj.Data.TemperatureRounded == obj.Temperatures(a);
                plot(obj.Data.Frequency(rows), subsref(obj.debyeFunctions(obj.DebyeFits{a, {'Xs', 'Xd', 'alpha', 'tau'}}, obj.Data.Frequency(rows)*2*pi), struct('type', '()', 'subs', {{':', 2}})), 'Color', [0 0 0]);
                scatter(obj.Data.Frequency(rows), obj.Data.ChiOut(rows), 10, 'filled', varargin{:});
                xlabel('Frequency (Hz)'); ylabel('\chi\prime\prime (emu mol^{-1})');
                set(gca, 'XScale', 'log', 'Box', 'on');
            end
            xlim([0.8 1250]);
            ylim([-0.1 5]);
        end
        
        function plotArrhenius(obj, varargin)
            figure;
            hold on;
            scatter(1./obj.Temperatures, log(obj.DebyeFits.tau), 10, 'filled', varargin{:});
            plot(1./obj.Temperatures, log(1./obj.relaxationFunction(obj.RelaxationFits, obj.Temperatures)));
            xlabel('Temperature'); ylabel('Time');
        end
    end
    
    methods (Access = private)
        function models = debyeFunctions(obj, b, x)
            models = ...
                [b(2)+(b(1)-b(2))*((1+power(x*b(4),1-b(3))*sin(pi*b(3)/2))./(1+2*power(x*b(4),1-b(3))*sin(pi*b(3)/2)+power(x*b(4),2*(1-b(3))))) ...
                (b(1)-b(2))*power(x*b(4),1-b(3))*cos(pi*b(3)/2)./((1+2*power(x*b(4),1-b(3))*sin(pi*b(3)/2)+power(x*b(4),(2*(1-b(3))))))];
        end
        
        function fitDebye(obj)
            x0 = [1e-4, 1e-1, 1e-3, 1e-3];
            lb = [-1, -1, 1e-7, 1e-7];
            ub = [40, 40, 1, 1];
            
            opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'SpecifyObjectiveGradient', false, ...
                'FunctionTolerance', 1e-22, 'OptimalityTolerance', 1e-20, 'StepTolerance', 1e-18, 'MaxFunctionEvaluations', 50000, 'MaxIterations', 50000, 'Display', 'off');
            for a = 1:length(obj.Temperatures)
                rows = obj.Data.TemperatureRounded == obj.Temperatures(a);
                [obj.DebyeFits(a,1:4), resnorm, resid, exitflag, output, lambda, J] = ...
                    lsqcurvefit(@obj.debyeFunctions, x0, obj.Data.Frequency(rows)*2*pi, [obj.Data.ChiIn(rows) obj.Data.ChiOut(rows)], lb, ub, opts);
            end
            obj.DebyeFits = array2table(obj.DebyeFits, ...
                'VariableNames', {'Xs', 'Xd', 'alpha', 'tau'});
        end
        
        function model = relaxationFunction(obj, b, x)
            model = b(1) + b(2)*x.^b(3) + b(4)*exp(-b(5)./(0.695 * x));
        end
        
        function fitRelaxation(obj)
            %{
            x0 = [50, 0, 0, 1e8, 130];
            lb = [0.1, 0, 0, 1e7, 50];
            ub = [100, 0, 0, 1e10, 200];
            %}
            x0 = [50, 1e-5, 6, 1e8, 130];
            lb = [0.1, 1e-10, 6, 1e7, 50];
            ub = [100, 1e-3, 6, 1e10, 200];
            %}
            opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'SpecifyObjectiveGradient', false, ...
                'FunctionTolerance', 1e-22, 'OptimalityTolerance', 1e-20, 'StepTolerance', 1e-10, 'MaxFunctionEvaluations', 50000, 'MaxIterations', 50000, 'Display', 'off');
            
            [obj.RelaxationFits, resnorm, resid, exitflag, output, lambda, J] = ...
                lsqcurvefit(@obj.relaxationFunction, x0, obj.Temperatures, 1./obj.DebyeFits.tau, lb, ub, opts);
        end
    end
    
end