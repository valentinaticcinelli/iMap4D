function answer = select_parameters4D()

%prompt={'Enter screen x in pixel','Enter screen y in pixel', 'Enter image x in pixel', 'Enter image y in pixel'};

prompt={'Starting Viewing Position','Number of points to sample the space in each dimension'};

name= ''; %'Input Parameters';
numlines=1;

defaultanswer = {'0 0 0','30'};
answer=inputdlg(prompt,name,numlines,defaultanswer);


