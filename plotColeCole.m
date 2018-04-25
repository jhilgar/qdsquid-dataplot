function plotColeCole(allIn)

    setDefaults();
    hold on;
    
    for a = 1:length(allIn{3})
        rows = allIn{2}.TemperatureRounded == allIn{3}(a);
        scatter(allIn{2}.ChiPrime(rows), allIn{2}.ChiDoublePrime(rows), 55,[allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)], 'filled');
        if length(allIn) == 6
            plot(subsref(fitFunctions(allIn{6}(a,1:4), allIn{2}.AcFreqRad(rows)), struct('type', '()', 'subs', {{':', 1}})),subsref(fitFunctions(allIn{6}(a,1:4), allIn{2}.AcFreqRad(rows)), struct('type', '()', 'subs', {{':', 2}})),'Color',[0 0 0]);
        end
    end

    xlabel('\chi\prime (emu mol^{-1})');
    ylabel('\chi\prime\prime (emu mol^{-1})');
    
end
