function varargout = imap4D_gui(varargin)
% IMAP4D_GUI MATLAB code for imap4D_gui.fig
%      IMAP4D_GUI, by itself, creates a new IMAP4D_GUI or raises the existing
%      singleton*.
%
%      H = IMAP4D_GUI returns the handle to a new IMAP4D_GUI or the handle to
%      the existing singleton*.
%
%      IMAP4D_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAP4D_GUI.M with the given input arguments.
%
%      IMAP4D_GUI('Property','Value',...) creates a new IMAP4D_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imap4D_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imap4D_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imap4D_gui

% Based on IMAP_GUI v2.5 05-May-2019 19:33:41
% Last modified: 18/05/2019 by Valentina Ticcinelli
% valentina.ticcinelli@unifr.ch

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @imap_gui_OpeningFcn, ...
    'gui_OutputFcn',  @imap_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before imap_gui is made visible.
function imap_gui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imap_gui (see VARARGIN)

% tbh = uitoolbar(handles.figure1);
% tth = uitoggletool(tbh,'CData',rand(20,20,3),...
%             'Separator','off',...
%             'HandleVisibility','off');
%         oldOrder = allchild(tbh);
% newOrder = flipud(oldOrder);
%output logo
if exist('logo_imap.png','file') == 2
    axes(handles.axes1);
    try
        imshow('logo_imap.png')
    catch
    end
else
    set(handles.axes1,'visible','off')
end
% Choose default command line output for imap_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(gcf,'center')

% UIWAIT makes imap_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = imap_gui_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in import_data.
function import_data_Callback(hObject, ~, handles)
% hObject    handle to import_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% hide the rest of buttons
%set(handles.check_columns, 'enable','off')
set(handles.select_parameters4D, 'enable','off');
set(handles.select_predictors, 'enable','off')
set(handles.smoothing_1, 'enable','off');
set(handles.smoothing_2, 'enable','off');
set(handles.rescale_method, 'enable','off');
set(handles.normalize_method, 'enable','off');
set(handles.mask_method,'enable','off');
set(handles.Modelling,'enable','off');


%reset variables
handles = reset_variables(handles,1);
guidata(hObject,handles);

% step 1: read the data
[filename, pathname, ~] = uigetfile({'*.*'},'File Selector','Multiselect','on');
fullpathname = strcat(pathname,filename);
if isempty(fullpathname)
    errordlg('No selected files, at least one file should be selected to proceed')
else
    if iscell(fullpathname)==0 % check if the user selets multiple or one file.
        [~ , ~, extension] = fileparts(filename);
        [ data,subject_in] = function_extension_file4D(pathname,filename,extension);
    else
        [~ , ~, extension] = fileparts(filename{1}); % get the extension of the file, all file should have the same extension
        [data,subject_in] = function_extension_multiplefile(pathname,filename,extension,handles);
    end
    
    if isempty(data)==0
        ncolumn = size(data,2);
        colnames = cell(1,ncolumn);
        for i = 1:ncolumn
            colnames(1,i) =cellstr(strcat('Column',num2str(i)));
        end
        NC = size(data,2); %number of column of data
        colnames = colnames(1:NC);
        
        sz_table = [820,400]; %size of table
        % size of label in GUI %sze_label = [120,40];
        size_panel = getpixelposition(handles.data_imported,true);
        size_panel_button = getpixelposition(handles.panel_button,true);
        % create table
        t = uitable(handles.figure1,'position',[size_panel(1)+20,size_panel_button(2)-450,sz_table(1),sz_table(2)],...
            'Data', data,'ColumnName', colnames,'RowName',[],'ColumnWidth','auto',...
            'Units','normalized','tag','table','RowStriping','off');
%         tableextent = get(t,'Extent');
%         oldposition = get(t,'Position');
%         if tableextent(3)<0.75
%             newposition = [oldposition(1) oldposition(2) tableextent(3) oldposition(4)];
%             set(t, 'Position', newposition);
%         end
        handles.table = t;
        
        set(handles.check_columns, 'enable','on')
        
        % update the handle with the data and column names
        handles.colnames = colnames;
        handles.colnames_original = colnames;
        handles.subject_in = subject_in;
        handles.data = data;
        handles.data_original = data; %save the original data
        guidata(hObject, handles);
    end
end

% --- Executes on button press in check_columns.
function check_columns_Callback(hObject, ~, handles)
% hObject    handle to check_columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hide buttons
set(handles.select_parameters4D, 'enable','off')
set(handles.select_predictors, 'enable','off')
set(handles.smoothing_1, 'enable','off');
set(handles.smoothing_2, 'enable','off');
set(handles.rescale_method, 'enable','off');
set(handles.normalize_method, 'enable','off');
set(handles.mask_method,'enable','off');

handles = reset_variables(handles,2);
guidata(hObject,handles);
[answer,new_data] = check_columns_file(handles);
set(handles.table,'columnname',answer)
handles.colnames = answer;
handles.data = new_data;
guidata(hObject, handles);

%create filename to save the results!
filename=datestr(now);
filename=strrep(filename,':','_'); %Replace colon with underscore
filename=strrep(filename,'-','_');%Replace minus sign with underscore
filename=strrep(filename,' ','_');%Replace space with underscore
mkdir(filename)
addpath(filename)
handles.filename = filename;
guidata(hObject,handles);
%% saving the column in the summary_information
if isunix ==0
    summary_information.column_name = handles.colnames ;
    save(strcat(handles.filename,'\summary_information'),'summary_information')
else
    summary_information.column_name = handles.colnames ;
    save(strcat(handles.filename,'/summary_information'),'summary_information')
end
%%
set(handles.import_model, 'enable','on')

% --- Executes on button press in import_model.
function import_model_Callback(hObject, ~, handles)
% % hide the rest of buttons
% set(handles.check_columns, 'enable','off')
% set(handles.select_parameters4D, 'enable','off');
% set(handles.select_predictors, 'enable','off')
% set(handles.smoothing_1, 'enable','off');
% set(handles.smoothing_2, 'enable','off');
% set(handles.rescale_method, 'enable','off');
% set(handles.normalize_method, 'enable','off');
% set(handles.mask_method,'enable','off');
% set(handles.Modelling,'enable','off');
% 

%reset variables
% handles = reset_variables(handles,1);
 %guidata(hObject,handles);

[filename, pathname, ~] = uigetfile({'*.*'},'File Selector','Multiselect','on');
fullpathname = strcat(pathname,filename);
obj = loadawobj(fullpathname);
obj.v=obj.v'; % uncomment this for the function loadawobj 
if isfield(obj,'f4')
obj.f4=obj.f4'; % uncomment this for the function loadawobj 
end
if isfield(obj,'f3')
obj.f3=obj.f3'; % uncomment this for the function loadawobj 
end
figure

colormap(parula)
if isfield(obj,'f3')
patch('Vertices', obj.v, 'Faces', obj.f3,'FaceVertexCData',ones(length( obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield(obj,'f4')
patch('Vertices', obj.v, 'Faces', obj.f4,'FaceVertexCData',ones(length( obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')
%colorbar
%caxis([0 100])
view ([180 -60])
axis off
set(gcf,'position',[ 547   155   842   727])

handles.obj=obj;
handles.number_vertices=dsearchn(obj.v ,[str2double(handles.data(:,3)) str2double(handles.data(:,4)) str2double(handles.data(:,5))]);
handles.data_vector=obj.v(handles.number_vertices,:);
guidata(hObject,handles);
saveas(gcf,[handles.filename,'/model.fig'])
set(handles.select_parameters4D, 'enable','on')

% --- Executes on button press in select_parameters4D.
function select_parameters4D_Callback(hObject, ~, handles)
% hObject    handle to select_parameters4D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% hide buttons
set(handles.select_predictors, 'enable','off')
set(handles.smoothing_1, 'enable','off');
set(handles.smoothing_2, 'enable','off');
set(handles.rescale_method, 'enable','off');
set(handles.normalize_method, 'enable','off');
set(handles.mask_method, 'enable','off');

handles = reset_variables(handles,3);
guidata(hObject,handles);

idx_answer = 1; % a condition to make sure that user inputs a value
while isempty(idx_answer)==0
    
    answer = select_parameters4D();
    
    if isempty(answer)
        % User clicked cancel.
        return;
    end
    
    if isempty(answer)==0
        idx_answer = find(strcmp(answer,'')==1);
        if isempty(idx_answer) ==0
            ed = errordlg('You need to input all parameters to proceed');
            waitfor(ed);
        end
    end
end
handles.start_position = answer{1};
handles.nPoints_resampled = str2double(answer{2});
guidata(hObject, handles);

%%
set(handles.select_predictors, 'enable','on')

% --- Executes on button press in select_predictors.
function select_predictors4D_Callback(hObject, ~, handles)
% hObject    handle to select_predictors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[answer_continuous, answer_categorical] = select_conditions(handles.colnames);

% hide buttons
set(handles.smoothing_1, 'enable','off');
set(handles.smoothing_2, 'enable','off');
set(handles.rescale_method, 'enable','off');
set(handles.normalize_method, 'enable','off');
set(handles.mask_method, 'enable','off');

handles = reset_variables(handles,4);
guidata(hObject,handles);

% select predictors
counter = 0;
[answer_continuous_default,answer_categorical_default,answer_continuous,answer_categorical,counter,handles] = select_conditions4D(hObject,handles,counter);

if counter == 1
    % update the handle
    handles.predictors_continuous = answer_continuous;
    handles.predictors_categorical = answer_categorical;
    handles.predictors_continuous_default = answer_continuous_default;
    handles.predictors_categorical_default = answer_categorical_default;

    guidata(hObject, handles);

    %give the user the oppurtunity to select specific or exclude fixations.
    prompt={'Do you have more than one fixation per trial? Insert 1 if you have only 1 fixation and 0 if you have more'};
    name = 'Number of fixations per trial';
    defaultans = {'0'};

    value = inputdlg(prompt,name,[1 50],defaultans);
    if isempty(value)==1
        value = 0;
    else
        value = str2double(value{:});
    end

    [data, counter2,mapType,check_number_fixations] = function_find_fixation4D(handles,value);
    handles.data = data;
    
    % user can select type of fixation map (1-fixation duration 2-fixation number)
    % mapType = type_fixation();
    handles.mapType = mapType;
    guidata(hObject,handles);
    if counter2 ==1 % counter to make sure that the user select one of the 3 choices

        if check_number_fixations == 1
            
            set(handles.smoothing_1, 'enable','on');
            set(handles.smoothing_2, 'enable','off');
        elseif check_number_fixations ==0
            
            set(handles.smoothing_1, 'enable','on');
        end
        % if isunix ==0
        %     save(strcat(handles.filename,'\handles'),'handles','-v7.3');
        %     else
        %     save(strcat(handles.filename,'/handles'),'handles','-v7.3');
        %
        % end
    end

    %% Saving the predictors in the summary information
    if isunix ==0
        summary_information.column_name = handles.colnames ;
        summary_information.parameters  = handles.start_position ;
        summary_information.predictors  = [{handles.predictors_categorical_default};{handles.predictors_continuous_default};...
            {handles.predictors_categorical};{handles.predictors_continuous}];
        save(strcat(handles.filename,'\summary_information'),'summary_information')
    else
        summary_information.column_name = handles.colnames ;
        summary_information.parameters  = handles.start_position;
        summary_information.predictors  = [{handles.predictors_categorical_default};{handles.predictors_continuous_default};...
            {handles.predictors_categorical};{handles.predictors_continuous}];
        save(strcat(handles.filename,'/summary_information'),'summary_information')
    end

end


%% --- Executes on button press in smoothing_1.
function smoothing_4D_Callback(hObject, ~, handles)
% hObject    handle to smoothing_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%hide button
set(handles.rescale_method, 'enable','off');
set(handles.normalize_method, 'enable','off');
set(handles.mask_method,'enable','off');
%remove the scaled and normalized data from the handles
% if (isfield(handles,'FixMap_single_trial')) ==1
%     handles = rmfield(handles,'FixMap_single_trial');
% end
%retrieve answers from user
categorical_conditions = handles.predictors_categorical; %find the categorical conditions selected by the user
continuous_conditions  = handles.predictors_continuous; %find the continuous conditions selected by the user
categorical_conditions_default = handles.predictors_categorical_default; %find the default categorical conditions selected by the user
continuous_conditions_default  = handles.predictors_continuous_default; %find the default continuous conditions selected by the user
% Trial = length(unique(str2double(handles.data(:,categorical_conditions_default.idx_categorical_default(2)))));
%create Gaussian for smoothing

[smoothingpic] = select_smoothing4D(handles,categorical_conditions_default,continuous_conditions,categorical_conditions,continuous_conditions_default);

handles.smoothingpic = smoothingpic;
guidata(hObject, handles);


%%  ADJUSTed THIS WITH 3D GAUSS!!!!
nPoints=handles.nPoints_resampled; %for each dimension
%smoothingpic  = 3;
% make 3d gaussian
gaussienne=gauss3d(nPoints,smoothingpic);

% xSize = str2double(handles.xy_size{3}); %image x in pixel
% ySize = str2double(handles.xy_size{4}); %image y in pixel
% [x, y] = meshgrid(-floor(xSize/2)+.5:floor(xSize/2)-.5, -floor(ySize/2)+.5:floor(ySize/2)-.5);
% gaussienne = exp(- (x .^2 / smoothingpic ^2) - (y .^2 / smoothingpic ^2));
% gaussienne = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));
% % f_fil = fft2(gaussienne);



%%
%threshold for mask
fixdurtmp = str2double(handles.data(:,continuous_conditions_default.idx_continuous_default(4)));
fixthres=(min(fixdurtmp)/3)*2;
handles.fixthres = fixthres;

% find the unique subjects
subject = handles.data(:,categorical_conditions_default.idx_categorical_default(1));
[subjlist,~,~]= unique(subject);
% number of subject
Ns=length(subjlist);
data_separated = cell(1,Ns);
h = waitbar(0,'Please wait smoothing is in progress','Name','Smoothing: Estimated','color','w');


for i = 1:length(subjlist)
    idx = strcmpi(subject,subjlist{i});
    data_separated{i} = handles.data(idx,:);
end

condition = cell(1,size(categorical_conditions,1));

for j = 1:size(categorical_conditions,1)
    cond = unique(handles.data(:,categorical_conditions.idx_categorical(j)));
    idx_empty = find(strcmp(cond,''))==1; %remove the empty cells that were not selected by the user
    if isempty(idx_empty)==0
        cond(idx_empty) =[];
    end
    condition{j} = cond;
end

combMat = allcombs(condition);
table_header = [categorical_conditions.predictors_categorical',... 
    continuous_conditions.predictors_continuous',... 
    continuous_conditions_default.predictors_continuous_default(4),...
    categorical_conditions_default.predictors_categorical_default(1)];
table_header2 = [{'FixNum'},{'sumFixDur'},{'meanFixDur'},{'totalPathLength'},...
    {'meanPathLength'},categorical_conditions.predictors_categorical',categorical_conditions_default.predictors_categorical_default(1)];
NcombMat = size(combMat,1);

nVertex=length(handles.obj.v);
%% ADJUSTed THIS WITH 3RD DIM
FixMap=zeros(Ns*NcombMat,nVertex);

%%
removeidx=zeros(Ns*NcombMat,1);
RawMap=FixMap;
PredictorM=[];
DescriptvM=[];
ii=0;
for is = 1:Ns
    if ~ishandle(h) %check if the user closes the waitbar
        break
    end
    sTable = data_separated{is};
    all_conditions=cell(size(combMat,1),1);
    descripM=cell(size(combMat,1),5);
    % Transform the data into double for continuous variable
    Seyext = str2double(sTable(:,continuous_conditions_default.idx_continuous_default(1)));
    Seyeyt = str2double(sTable(:,continuous_conditions_default.idx_continuous_default(2)));
    Seyezt = str2double(sTable(:,continuous_conditions_default.idx_continuous_default(3)));
    Intv   = str2double(sTable(:,continuous_conditions_default.idx_continuous_default(4)));
    TrialN = sTable(:,categorical_conditions_default.idx_categorical_default(2));
    
    % construct fixation map matrix and design matrix
    jj = 0;
    for it=1:size(combMat,1)
        iindex = retrieve_table_conditions(combMat(it,:),sTable,categorical_conditions.idx_categorical); % we do not take into account the trial and subject
        idx = find(iindex==1);
        ii=ii+1;
        if sum(iindex)~=0
            [Trial,bb]=unique(TrialN(idx));
            Ntt=length(Trial);
            rawmaptmp=zeros(Ntt,nVertex);
            fixmaptmp=rawmaptmp;
            Tridur=zeros(Ntt,1);
            % descriptive measurements
            descriptemp=zeros(Ntt,5);% fixation number, sum of fixation duraion, mean of fixation duration, total path length, mean path length
            for itt=1:Ntt
                idx2=idx(strcmp(TrialN(idx),Trial{itt}));
                % fixation matrix according to the combination
                seyext = Seyext(idx2);
                seyeyt = Seyeyt(idx2);
                seyezt = Seyezt(idx2);
                intv   = Intv(idx2);
                % exclude zeros or negative
                exclist=intv<=0;seyext(exclist)=[];seyeyt(exclist)=[];intv(exclist)=[];
                % descriptive
                % fixation number, sum of fixation duraion, mean of fixation duration, total path length, mean path length
                pathlength=diag(squareform(pdist([seyext,seyeyt,seyeyt])),1);
                descriptemp(itt,1)=length(intv);
                descriptemp(itt,2)=sum(intv);
                descriptemp(itt,3)=mean(intv);
                descriptemp(itt,4)=sum(pathlength);
                descriptemp(itt,5)=mean(pathlength);
                if handles.mapType==2
                    intv=ones(size(intv));
                end
                
%                 coordX = round(seyeyt);%switch matrix coordinate here
%                 coordY = round(seyext);
%                 indx1=coordX>0 & coordY>0 & coordX<ySize & coordY<xSize;
                
                %%    changed this!!
                indV = dsearchn(handles.obj.v, [seyext seyeyt seyezt]);
                rawmap=zeros(nVertex,1);
                rawmap(indV)=intv ;
                % transform obj into a linear space
                [spaceObj,indLinPointsInSpace] =linObjgen(handles.obj,nPoints,indV,intv);


                % pass to FFT and filter
                f_obj          = fftn(spaceObj); 
                filtered_mat=gaussienne.*f_obj;
                smoothpic      = abs(fftshift(ifftn(filtered_mat)));%/sqrt(smoothingpic);

                % get the color for each vertices from the inverse transformed 3D map
                for i=1:length(indLinPointsInSpace)
                    valFilt(i)=smoothpic(indLinPointsInSpace(i,1),indLinPointsInSpace(i,2),indLinPointsInSpace(i,3));
                end

%                 rawmap=full(sparse(coordX(indx1),coordY(indx1),intv(indx1),ySize,xSize));
                
%                 f_mat = fft2(rawmap); % 2D fourrier transform on the points matrix
%                 filtered_mat = f_mat .* f_fil;
%                 smoothpic = real(fftshift(ifft2(filtered_mat)));
                
           %     smoothpic = conv2(rawmap, gaussienne,'same');
                
                
       %%         
                Tridur(itt,1)=nansum(intv);
                rawmaptmp(itt,:)=rawmap;
                fixmaptmp(itt,:)=valFilt;
            end
            FixMap(ii,:)=nanmean(fixmaptmp,1);
            RawMap(ii,:)=nanmean(rawmaptmp,1);
            
            jj=jj+1;
            %mean of all conditions
            if isempty(continuous_conditions)==1
                all_conditions{jj,1} = nanmean(Tridur);
            else
                for j = 1:length(continuous_conditions)
                    all_conditions{jj,j} = nanmean(str2double(sTable(bb,continuous_conditions.idx_continuous(j))));%mean of the selectd conditions by the user
                end
                all_conditions{jj,j+1} = nanmean(Tridur);
            end
            descripM(jj,:)=num2cell(mean(descriptemp,1));
        else
            removeidx(ii)=1;
            jj=jj+1;
            if isempty(continuous_conditions)==1
                all_conditions{jj,1} = NaN;
            else
                for j = 1:length(continuous_conditions)
                    all_conditions{jj,j} = NaN;
                end
                all_conditions{jj,j+1} = NaN;
            end
            descripM(jj,:)=num2cell(NaN(1,5));
        end
        
    end
    
    idx_subject = cell(jj,1);
    idx_subject(:) = cellstr(subjlist(is));
    sTable2= [num2cell(combMat),all_conditions,idx_subject];
    sTabled= [descripM,num2cell(combMat),idx_subject];
    PredictorM = [PredictorM;sTable2];
    DescriptvM = [DescriptvM;sTabled];
    waitbar(is /Ns)
    
end


removeidx=logical(removeidx);
PredictorM(removeidx,:)=[];
DescriptvM(removeidx,:)=[];
FixMap(removeidx,:)=[];
RawMap(removeidx,:)=[];

if ishandle(h) % if the user did not close the wait bar menu
    delete(h)
    
    PredictorM = [table_header;PredictorM];
    PredictorM = cell2dataset(PredictorM);
    DescriptvM = [table_header2;DescriptvM];
    DescriptvM = cell2dataset(DescriptvM);
    
    %Transform PredictorM to nominal for modelling
    all_categorical_conditions = [categorical_conditions_default.predictors_categorical_default;categorical_conditions.predictors_categorical];
    PredictorM = nominal_predictorM(all_categorical_conditions,continuous_conditions_default.predictors_continuous_default{4},PredictorM);
    
    %duration_column
    duration_column = handles.predictors_continuous_default{4,1};
    idx_duration = strcmp(duration_column,table_header)==1;
    handles.duration_estimated = PredictorM(:,idx_duration);
    
    % update handles
    handles.PredictorM_estimated = PredictorM;
    handles.RawMap_estimated = RawMap;
    handles.FixMap_estimated = FixMap;
    %calculate the Mask
    Mask = squeeze(nanmean(FixMap,1))>fixthres;
    handles.Mask_estimated = Mask;
    guidata(hObject, handles);
    
    h=msgbox('Saving... Please wait...');
    set(h,'color','white');
    delete(findobj(h,'string','OK')); delete(findobj(h,'style','frame'));
    set(handles.figure1, 'pointer', 'watch')
    drawnow;
    
    
    
    
   %% till here! add obj in the fixmat saving!!! 
    
    
    
    
    
    obj=handles.obj;
    folder_name=handles.filename;
    
   
    if isunix ==0
      %%%  save(strcat(handles.filename,'\Handles'),'handles','-v7.3');
        save(strcat(handles.filename,'\FixMap_estimated'),'FixMap','obj','folder_name','-v7.3');
        save(strcat(handles.filename,'\PredictorM_estimated'),'PredictorM','folder_name','-v7.3');
        save(strcat(handles.filename,'\DescriptvM_estimated'),'DescriptvM','folder_name','-v7.3');
        save(strcat(handles.filename,'\RawMap_estimated'),'RawMap','obj','folder_name','-v7.3');
        save(strcat(handles.filename,'\Mask_estimated'),'Mask','obj','folder_name','-v7.3');
        %save(strcat(handles.filename,'\handles'),'handles','-v7.3');
        summary_information.column_name = handles.colnames ;
        summary_information.parameters  = handles.start_position ;
        summary_information.predictors  = [{handles.predictors_categorical_default};{handles.predictors_continuous_default};...
            {handles.predictors_categorical};{handles.predictors_continuous}];
        summary_information.smoothing   = handles.smoothingpic;
        summary_information.mask        =  handles.fixthres;
        save(strcat(handles.filename,'\summary_information'),'summary_information')
    else
     %%   save(strcat(handles.filename,'/Handles'),'handles','-v7.3');
        save(strcat(handles.filename,'/FixMap_estimated'),'FixMap','obj','folder_name','-v7.3');
        save(strcat(handles.filename,'/PredictorM_estimated'),'PredictorM','folder_name','-v7.3');
        save(strcat(handles.filename,'/DescriptvM_estimated'),'DescriptvM','folder_name','-v7.3');
        save(strcat(handles.filename,'/RawMap_estimated'),'RawMap','obj','folder_name','-v7.3');
        save(strcat(handles.filename,'/Mask_estimated'),'Mask','obj','folder_name','-v7.3');
        %save(strcat(handles.filename,'/handles'),'handles','-v7.3');
        summary_information.column_name = handles.colnames ;
        summary_information.parameters  = handles.start_position ;
        summary_information.predictors  = [{handles.predictors_categorical_default};{handles.predictors_continuous_default};...
            {handles.predictors_categorical};{handles.predictors_continuous}];
        summary_information.smoothing   = handles.smoothingpic;
        summary_information.mask        =  handles.fixthres;
        save(strcat(handles.filename,'/summary_information'),'summary_information')
    end
    if ishandle(h)
        delete(h)
    end
    set(handles.figure1, 'pointer', 'arrow')
    set(handles.rescale_method, 'enable','off');
    set(handles.normalize_method, 'enable','on');
    set(handles.mask_method,'enable','on');
    hMsg = msgbox(strcat('Smoothing done. PredictorM, DescriptvM, RawMap, FixMap and the Mask are saved in',{' '},handles.filename));
    set(hMsg, 'color', 'white');
    
    set(handles.Modelling,'enable','on');
end

% --- Executes on button press in mask_method.
function mask_method_Callback(hObject, ~, handles)
% hObject    handle to mask_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

check_trial = isfield(handles,'FixMap_single_trial_scaled');
check_estimated = isfield(handles,'FixMap_estimated');

if (check_trial == 1) && (check_estimated == 1)
    answer = 1;
    answer_user=questdlg('Would you like to visualize the mask of the Estimated Method or Single trial Method?','','Estimated Method','Single-Trial Method','Single-Trial Method');
    
    if strcmp(answer_user,'Estimated Method');
        Mask = handles.Mask_estimated;
        FixMap = handles.FixMap_estimated;
    else
        Mask = handles.Mask_single_trial_scaled;
        FixMap = handles.FixMap_single_trial_scaled;
    end
    while answer == 1
        [answer, Mask,fixthres] = select_mask_parameter4D(FixMap,Mask,handles);
    end
    if isempty(answer)==0
        handles.fixthres = fixthres;
        if (strcmp(answer_user,'Estimated Method'));
            handles.Mask_estimated = Mask;
            guidata(hObject,handles)
            if isunix==0
                save(strcat(handles.filename,'\Mask_estimated'),  'Mask','-v7.3')
            else
                save(strcat(handles.filename,'/Mask_estimated'),  'Mask','-v7.3')
            end
            if isfield(handles,'FixMap_estimated_scaled')
                Mask = squeeze(nanmean(handles.FixMap_estimated_scaled,1))>fixthres;
                handles.Mask_estimated_scaled = Mask;
                if isunix==0
                    save(strcat(handles.filename,'\Mask_estimated_scaled'),  'Mask','-v7.3')
                else
                    save(strcat(handles.filename,'/Mask_estimated_scaled'),  'Mask','-v7.3')
                end
            end
        else
            handles.Mask_single_trial_scaled = Mask;
            guidata(hObject,handles)
            %  Mask = squeeze(mean(handles.FixMap_single_trial_scaled,1))>fixthres;
            %  handles.Mask_single_trial_scaled = Mask;
            
            if isunix==0
                save(strcat(handles.filename,'\Mask_single_trial_scaled'),  'Mask','-v7.3')
            else
                save(strcat(handles.filename,'/Mask_single_trial_scaled'),  'Mask','-v7.3')
            end
        end
    end
else if (check_trial)==1
        answer =  1;
        Mask =  handles.Mask_single_trial_scaled;
        FixMap = handles.FixMap_single_trial_scaled;
        while answer == 1
            [answer, Mask, fixthres] = select_mask_parameter4D(FixMap,Mask,handles);
        end
        if isempty(answer)==0
            handles.Mask_single_trial_scaled = Mask;
			handles.fixthres = fixthres;
            guidata(hObject,handles)
        end
    else
        answer =  1;
        Mask =  handles.Mask_estimated;
        FixMap = handles.FixMap_estimated;
        while answer == 1
            [answer, Mask, fixthres] = select_mask_parameter4D(FixMap,Mask,handles);
        end
        if isempty(answer)==0
            handles.Mask_estimated = Mask;
            guidata(hObject,handles)
            if isunix==0
                save(strcat(handles.filename,'\Mask_estimated'),  'Mask','-v7.3')
            else
                save(strcat(handles.filename,'/Mask_estimated'),  'Mask','-v7.3')
            end
            if isfield(handles,'FixMap_estimated_scaled')
                Mask = squeeze(nanmean(handles.FixMap_estimated_scaled,1))>fixthres;
                handles.Mask_estimated_scaled = Mask;
                if isunix==0
                    save(strcat(handles.filename,'\Mask_estimated_scaled'),  'Mask','-v7.3')
                else
                    save(strcat(handles.filename,'/Mask_estimated_scaled'),  'Mask','-v7.3')
                end
            else
                if isunix==0
                    save(strcat(handles.filename,'\Mask_estimated'),  'Mask','-v7.3')
                else
                    save(strcat(handles.filename,'/Mask_estimated'),  'Mask','-v7.3')
                end
            end
        end
    end
end

%--- %Executes on button press in normalize_method
function normalize_method_Callback(~, ~, handles)
% hObject    handle to normalize_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

size_figure = [340,80];
screensize = get(0,'ScreenSize');
xpos_1 = ceil((screensize(3)-size_figure(2))/2); % center the figure on the screen horizontally
ypos_1 = ceil((screensize(4)-size_figure(1))/2); % center the figure on the screen vertically

%300,200
S.fh = figure('units','pixels',...
    'position',[xpos_1 ypos_1 size_figure(1) size_figure(2)],...
    'menubar','none',...
    'name','Normalization Options',...
    'numbertitle','off',...
    'resize','off');

%movegui(S.fh,'center');

% type fixation
type_fixation = {'Duration','Z-score'};
% create checkboxes
hBtnGrp = uibuttongroup('Position',[0 -0.02  100 400]);
%set(hBtnGrp,'color','white');

boxhandles(1) =  uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off',...
    'Position',[80 30  80 20], 'String',type_fixation{1}) ;

boxhandles(2) =  uicontrol('Style','Radio', 'Parent',hBtnGrp, 'HandleVisibility','off',...
    'Position',[180 30  80 20], 'String',type_fixation{2}) ;

r = {'Select the normalization option for smoothing?'};
S.text_general = uicontrol('style','text','string',r,'position',[10 60 300  15],...
    'HorizontalAlignment','center','FontWeight','Bold','Backgroundcolor','white');

sz_pshb1 = [70,20];
uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Validate','position',[85 3.5 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',{@validate_normalization_smoothing,boxhandles,S,handles});
set(hBtnGrp,'SelectedObject', boxhandles(1));

uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Cancel','position',[165 3.5 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@cancel_normalization_smoothing);
set(S.fh,'color','white')
uiwait(gcf)

%local callback functions
function    validate_normalization_smoothing(~,~,boxhandles,S,handles)

% get values of checkboxes and extract selected predictors
uiresume(gcf)

%retrieve the choice of the uster
choice_user = find(cell2mat(get(boxhandles,'Value'))==1);
close(gcf);
switch choice_user
    case 1
        normalization(handles,S,choice_user);%normalization duration
    case 2
        normalization(handles,S,choice_user);%normalization z-score
end

function   cancel_normalization_smoothing(~,~)
uiresume(gcf)
delete(gcf);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%             !!!!!!!!                 TILL  HERE           !!!!!!!!!!!!!!!!!!
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% --- Executes on button press in Modelling.
function Modelling_Callback(hObject,~,handles)
% hObject    handle to Modelling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);
clear all

%% Asking the user if he wants to see the descriptive statistics
answer_descriptive = questdlg('Would you like to see the descriptive statistics?','','Yes','Skip','Skip');

%% descriptive results
if isempty(answer_descriptive)==0
if strcmp(answer_descriptive,'Yes')==1;

descriptive_part4D();
else
modelling_part4D()
end
%% Modelling Analysis
else
clear all
modelling_part4D()
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, ~, ~)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
axes(hObject)
if exist('logo_imap.png','file') == 2
    imshow('logo_imap.png');
else
    %h=findobj(handles.a,'type','image');
    set(hObject,'visible','off')
end

% --------------------------------------------------------------------
% function help_button_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to help_button (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % if ispc
% %     winopen('manual_GUI.pdf');
% % elseif ismac
% %     system(['open manual_GUI.pdf']);
% % else
% %     errordlg('Please open the Guidebook manually in ./matlab/Apps/iMAP/GUI')
% % end
% web('https://github.com/iBMLab/iMap4/wiki','-browser')
