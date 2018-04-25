function plotACIn(allIn)
    
    setDefaults();
    hold on;
    
    for a = 1:length(allIn{3})
        rows = allIn{2}.TemperatureRounded == allIn{3}(a);
        scatter(allIn{2}.AcFreq(rows), allIn{2}.ChiPrime(rows), 55,[allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)], 'filled');
        if length(allIn) == 6
            plot(allIn{2}.AcFreq(rows),subsref(fitFunctions(allIn{6}(a,1:4), allIn{2}.AcFreqRad(rows)), struct('type', '()', 'subs', {{':', 1}})),'Color',[0 0 0]);
        end
    end

    xticks([1 10 100 1000]);
    xticklabels({'1', '10', '100', '1000'});
    xlabel('Frequency (Hz)');
    ylabel('\chi\prime (emu mol^{-1})');
    set(gca,'XScale','log');
    
end