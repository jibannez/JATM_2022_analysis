function data = plot_participant(data)
% Copyright 2022 Jorge Ibáñez Gijón.
import util.vline
figure()
if isfield(data.HR,'orig_offset')
    plot(data.HR.time-data.HR.orig_offset,data.HR.values);
else
    plot(data.HR.time,data.HR.values);
end
hold on; 
if isfield(data.EDA,'orig_offset')
    plot(data.EDA.time-data.EDA.orig_offset,data.EDA.values*mean(data.HR.values));
else
    plot(data.EDA.time,data.EDA.values*mean(data.HR.values));
end

if isfield(data.ACC,'orig_offset')
    plot(data.ACC.time-data.ACC.orig_offset,data.ACC.values*mean(data.HR.values)/200);
else
    plot(data.ACC.time,data.ACC.values*mean(data.HR.values)/200);
end

if isfield(data.IBI2,'orig_offset')
    scatter(data.IBI2.time-data.IBI2.orig_offset,data.IBI2.values*100);
else
    scatter(data.IBI2.time,data.IBI2.values*100);
end

if isfield(data.BVP,'orig_offset')
    plot(data.BVP.time-data.BVP.orig_offset,data.BVP.values/100);
else
    plot(data.BVP.time,data.BVP.values/100);
end

legend({'HR','EDA','ACC','IBI2','BVP'})
vline(data.tags.time)
vline(0,'k')
%xlim([data.EDA.time(1) data.EDA.time(end)])

end
