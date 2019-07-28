function parseWaveformData(obj, waveformData)
    idxs = obj.findDataBlocks(waveformData, 10);

    for a = 1:(length(idxs) - 1)
        start = idxs(a);
        stop = idxs(a + 1) - 1;
        waveform = waveformData.Raw(start:stop, :);

        numPoints = height(waveform);
        measureTime = waveform.Time(end) - waveform.Time(1);
        sampleRate = numPoints / measureTime;

        paren = @(x,varargin) x(varargin{:});
        dftm = paren(fft(waveform.Moment, numPoints), 1:numPoints / 2 + 1);
        dftf = paren(fft(waveform.Field, numPoints), 1:numPoints / 2 + 1);

        newSpectrum = array2table(...
            [ones(length(dftm), 1)*(round(waveform.Temperature(1) / 0.05) * 0.05), ...
            (0 : sampleRate / numPoints : sampleRate / 2)', ...
            dftm, ...
            dftf], ...
            'VariableNames', obj.WaveformFieldsSpectra);
        obj.Spectra = [obj.Spectra; newSpectrum];

        [m_dftm, i_dftm] = max(abs(newSpectrum.hsDFTM));
        [m_dftf, i_dftf] = max(abs(newSpectrum.hsDFTF));
        phi = angle(newSpectrum.hsDFTF(i_dftf)/newSpectrum.hsDFTM(i_dftm));
        chi = m_dftm / m_dftf / waveformData.Header.Moles;

        newParsed = array2table(...
            [newSpectrum.TemperatureRounded(1), ...
            newSpectrum.Frequency(i_dftf), ...
            chi*cos(phi), ...
            chi*sin(phi), ...
            phi], ...
            'VariableNames', obj.WaveformFieldsParsed);
        obj.Parsed = [obj.Parsed; newParsed];
    end

    obj.Parsed = sortrows(obj.Parsed, {'TemperatureRounded', 'Frequency'});
end