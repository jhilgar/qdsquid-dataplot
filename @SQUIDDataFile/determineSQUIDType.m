function idx = determineSQUIDType(obj, contents)
    if contains(contents{1}{2}, 'MPMS3')
        idx = find(contains(obj.SQUIDTypes, 'MPMS3'));
    elseif contains(contents{1}{2}, 'TITLE,MPMS')
        idx = find(contains(obj.SQUIDTypes, 'MPMSXL'));
    else
        idx = 0;
    end
end