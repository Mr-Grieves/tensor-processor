function truth = is_member_of(query, listof)
truth = 0;
for i = 1:size(listof,1)
    if strcmp(query, listof(i,:))
        truth = 1;
        return
    end
end
