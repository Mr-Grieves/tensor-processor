function truth = is_best_of(query, last, best)
truth = 0;
for i = 1:size(list,1)
    if strcmp(query, list(i,:))
        truth = 1;
        return
    end
end
