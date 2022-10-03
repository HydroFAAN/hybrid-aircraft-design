function common = find_common(A,B)
    ind=numel(A);
    for i=1:ind
        if isempty(find(abs(B-A(i)) < 0.1,1))==false
            common = i;
            break
        end
    end
end
