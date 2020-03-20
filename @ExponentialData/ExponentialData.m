classdef ExponentialData < TauData
    properties
        FitType = 'none';
        nE = [];
        nSE = [];
    end

    properties (Access = protected)
        x0Stretched = [100, 0.5, 10];
        lbStretched = [1, 0, 0];
        ubStretched = [1e6, 1, 1000];
        
        x0Bi = [10, 100, 0.5, 10];
        lbBi = [1, 1, 0, 0];
        ubBi = [1e6, 1e6, 1, 1000];
        
        ExponentialBounds;
    end

    properties (Access = protected, Constant)
        FitOpts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');

        ExponentialFieldsParsed = {'Time', 'TemperatureRounded', 'Moment'};

        ModelFields = {'Time', 'TemperatureRounded', 'MomentModel'};

        BiExponentialFitFields = {'TemperatureRounded', 'tau1', 'tau2', 'A12', 'Mf'};
        BiExponentialErrorFields = {'TemperatureRounded', 'tau1Pos', 'tau1Neg', 'tau2Pos', 'tau2Neg', 'A12Pos', 'A12Neg', 'MfPos', 'MfNeg'};

        StretchedExponentialFitFields = {'TemperatureRounded', 'tau', 'beta', 'Mf'};
        StretchedExponentialErrorFields = {'TemperatureRounded', 'tauPos', 'tauNeg', 'betaPos', 'betaNeg', 'MfPos', 'MfNeg'};

        ExponentialNames = {'bi', 'stretched'};
        ExponentialFitFunctions = {@ExponentialData.BiExponentialFunction, @ExponentialData.StretchedExponentialFunction};
        ExponentialFits = {ExponentialData.BiExponentialFitFields, ExponentialData.StretchedExponentialFitFields};
        ExponentialErrors = {ExponentialData.BiExponentialErrorFields, ExponentialData.StretchedExponentialErrorFields};
    end

    methods
        fitTau(obj, fitType);
        fitTau2(obj, varargin);

        function obj = ExponentialData(varargin)
            obj = obj@TauData(varargin{:});
            obj.Parsed = cell2table(cell(0, length(obj.ExponentialFieldsParsed)), 'VariableNames', obj.ExponentialFieldsParsed);
            
            BiExponentialBounds = [obj.x0Bi; obj.lbBi; obj.ubBi];
            StretchedExponentialBounds = [obj.x0Stretched; obj.lbStretched; obj.ubStretched];
            obj.ExponentialBounds = {BiExponentialBounds, StretchedExponentialBounds};
            
            for a = 1:length(obj.DataFiles)
                obj.parseExponentialData(obj.DataFiles(a));
            end
        end
    end

    methods (Access = private)
        parseExponentialData(obj, exponentialData)
    end

    methods (Static)
        function output = model(xdata, e, se, b, m0)
            ycalc = 0;

            for a = 1:e
                ycalc = ycalc + ExponentialData.Exponential([b(((a - 1) * 2 + 1):((a - 1) * 2 + 2)), b(end)], xdata, m0);
            end

            for a = 1:se
                ycalc = ycalc + ExponentialData.StretchedExponential([b(((a - 1) * 3 + 1 + (e * 2)):((a - 1) * 3 + 3 + (e * 2))), b(end)], xdata, m0);
            end

            output = ycalc + b(end);
        end

        function output = Exponential(b, time, m0)
            output = (m0 * b(2)).*exp(-time ./ b(1));
        end

        function output = StretchedExponential(b, time, m0)
            output = (m0 * b(3)).*exp(-(time ./ b(1)).^b(2));
        end
    end
end