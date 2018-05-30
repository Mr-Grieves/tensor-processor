function view = get_view(string,qus_format)
if(qus_format)
    if     strcmp(string(14:16),'SUB') view = 'SUBC4';
    elseif strcmp(string(14:16),'AP4') view = 'AP4';
    elseif strcmp(string(14:16),'PLA') view = 'PLAX';
    elseif strcmp(string(14:16),'PSA') view = 'PSAXPM';
    else
        warning(['NO VIEW DETECTED in ' string]);
        view = 'null';
    end
else
    if     strfind(string,'SUB') view = 'SUBC4';
    elseif strfind(string,'AP4') view = 'AP4';
    elseif strfind(string,'PLA') view = 'PLAX';
    elseif strfind(string,'PSA') view = 'PSAXPM';
    else
        warning(['NO VIEW DETECTED in ' string]);
        view = 'null';
    end
end