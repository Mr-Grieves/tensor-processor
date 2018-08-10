function idx = get_view_index(view)

if     strcmp(view,'SUBC4') idx = 6;
elseif strcmp(view,'AP4')   idx = 2;
elseif strcmp(view,'PLAX')  idx = 4;
elseif strcmp(view,'PSAXPM')idx = 11;
else
    warning(['NO INDEX DETECTED in ' view]);
    idx = -1;
end
end