function k = find_silence(st,stmfs,i)
for k=i:numel(st)
    k
    if std(st(k:k+ceil(0.025.*stmfs)))<=0.001
        disp('breaking')
        k=k+ceil(0.025.*stmfs) % refractory period
        return
    end
end
