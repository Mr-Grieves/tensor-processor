function view = get_view(string)
if     strfind(string,'SUB') view = 'SUBC4';
elseif strfind(string,'AP4') view = 'AP4';
elseif strfind(string,'PLA') view = 'PLAX';
elseif strfind(string,'PSA') view = 'PSAXPM';
else
    warning(['NO VIEW DETECTED in ' string]);
    view = 'null';
end
        