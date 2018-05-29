function curr_time = get_time(filename)

hr = str2num(filename(1:2));
mins = str2num(filename(4:5));
sec = str2num(filename(7:8));
ms = str2num(filename(10:12));
curr_time = hr*3600+mins*60+sec+ms/1000;

