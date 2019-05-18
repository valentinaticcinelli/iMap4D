function mccopt = select_option_mcc4D()
%temporarly commented statistics to adapt to 4D
mccopt = struct;
%prompt = {'Method:';'tfce:     '};
prompt = {'Method:'};
name = 'MCC options';
formats = struct('type', {}, 'style', {}, 'items', {},'format', {}, 'limits', {}, 'size', {});
formats(1,1).type   = 'list';
formats(1,1).format = 'integer';
formats(1,1).size = 80;
%formats(1,1).items  = {'fdr','bonferroni','randomfield','cluster','bootstrap','permutation'};
formats(1,1).items  = {'fdr','bonferroni','randomfield'};%,'cluster','bootstrap','permutation'};
formats(1,1).style  = 'popupmenu';

% formats(2,1).type   = 'list';
% formats(2,1).size = 50;
% formats(2,1).style  = 'popupmenu';
% formats(2,1).items  = {'0','1'};

%defaultanswer = {5,1};
defaultanswer = {1};

answer = inputsdlg(prompt, name, formats, defaultanswer);
mccopt.methods = formats(1,1).items{answer{1}};
%mccopt.tfce   = str2double(formats(2,1).items{answer{2}});
mccopt.tfce   = 0;
