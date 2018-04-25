function plotACFreq(allIn)

    figure;
    
    subplot(2, 2, 1);
    plotACIn(allIn);
    subplot(2, 2, 2);
    plotACOut(allIn);
    subplot(2, 2, 3);
    plotColeCole(allIn);
    subplot(2, 2, 4);
    plotArrhenius(allIn);
    
end

