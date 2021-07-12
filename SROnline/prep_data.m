data = {};
for id = [101,102,103,105,106,108,110,111,112,113,114,115,116,117,118,119,120,121,122,123,125,126,127,129,130,131,132,133,134,135];

    ppt = string(id);
    file = 'C:\Users\Brendan\University of Reading\neuroade - Projects\project_SRfMRI\data\SRfMRI_' + ppt + '\SRfMRI_' + ppt + '.txt';
    df = readtable(file);
    if id ~= 103 && id ~= 110 && id ~= 112 && id ~= 117 && id ~= 118 && id ~= 119 && id ~= 123 && id ~= 127
        out.actions = table2array(df(:,7));
        out.actions(out.actions(:,1) ==0)=[];
        out.outcome = table2array(df(:,15)) / 50;
        out.outcome(out.outcome(:,1) ==0)=[];
        out.side = string(table2array(df(:,14)));
        out.side(out.side(:,1) =='NaN')=[];
        out.right = out.side;
        out.right(out.right(:,1) == "r") = 1;
        out.right(out.right(:,1) == "b") = 0;
        out.right = str2double(out.right);
        data{end+1} = out;
    else 
        out.actions = table2array(df(:,7));
        out.actions(out.actions(:,1) ==0)=[];
        out.outcome = table2array(df(:,16)) / 50;
        out.outcome(out.outcome(:,1) ==0)=[];
        out.side = string(table2array(df(:,15)));
        out.side(out.side(:,1) =='NaN')=[];
        out.right = out.side;
        out.right(out.right(:,1) == "r") = 1;
        out.right(out.right(:,1) == "b") = 0;
        out.right = str2double(out.right);
        data{end+1} = out;        
    end

end
data = reshape(data, 30, 1);
save('all_data.mat', 'data')