function idxs = findDataBlocks(obj, data, time)
    idxs = [1];
    for a = 2:height(data.Raw)
        if ((data.Raw.Time(a) - data.Raw.Time(a - 1)) > time)
            idxs = [idxs a];
        end
    end
    idxs = [idxs height(data.Raw)];
end