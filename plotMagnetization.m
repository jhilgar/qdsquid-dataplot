function plotMagnetization(allIn)
    
    figure;
    hold on;
    setDefaults();
    
    for a = 1:(length(allIn{3}))
        rows = allIn{2}.TemperatureRounded == allIn{3}(a);
        
        scatter(allIn{2}.Field(rows) ./ 10000 ,allIn{2}.Magnetization(rows),55, [allIn{2}.Red(rows) allIn{2}.Green(rows) allIn{2}.Blue(rows)], 'filled');
        plot(allIn{2}.Field(rows) ./ 10000 ,allIn{2}.Magnetization(rows),'Color', [0 0 0]);
    end

    xlabel('\itH\rm\bf (T)');
    ylabel('\it\mu\rm_{B}\bf (emu mol^{-1})');
    axis square;

end