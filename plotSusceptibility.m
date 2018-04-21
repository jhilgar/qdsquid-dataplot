function plotSusceptibility(allIn)

    figure;
    hold on;
    fields = unique(allIn{2}.Field);
    setDefaults();
    
    for a = 1:length(fields)
       rows = allIn{2}.Field == fields(a);
       scatter(allIn{2}.Temperature(rows), allIn{2}.ChiT(rows), 55, [allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)], 'filled');
       plot(allIn{2}.Temperature(rows), allIn{2}.ChiT(rows), 'Color', [0 0 0]);
    end

    xlabel('\itT\rm\bf (K)');
    ylabel('\it\chiT\rm\bf (emu K mol^{-1})');
    axis square;
    
end