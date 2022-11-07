function detect_tbl_changes(tbl1, tbl2)
% detect_tbl_changes Detects changes between tables columns
% Copyright 2022 Jorge Ibáñez Gijón.
vnames = tbl1.Properties.VariableNames;
vno = length(vnames);
for vi=1:vno
    v = vnames{vi};
    if any(tbl1.(v) - tbl2.(v))
        disp(v);
    end
end
