function output = loadData()
    file = uigetfile('*.dat', 'MultiSelect', 'on');
    if ~iscell(file), file = {file}; end

    runTypes = {'MvsT', 'MvsH', 'ACvsF', 'Waveform', 'Relaxation'};
    classTypes = {@SusceptibilityData, @MagnetizationData, @ACData, @WaveformData, @Relaxation};

    for a = 1:length(runTypes)
       if contains(file, runTypes{a})
          output = classTypes{a}(file{:});
          break;
       end
    end
end