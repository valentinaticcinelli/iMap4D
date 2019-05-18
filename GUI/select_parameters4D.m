function answer = select_parameters4D()

% in a future development the viewer starting position will be taken into
% account for distance/smoothing parameter considerations
% Last modified: 18/05/2019 by Valentina Ticcinelli
% valentina.ticcinelli@unifr.ch

prompt={'Starting Viewing Position','Number of points to sample the space in each dimension'};

name= ''; %'Input Parameters';
numlines=1;

defaultanswer = {'0 0 0','30'};
answer=inputdlg(prompt,name,numlines,defaultanswer);


