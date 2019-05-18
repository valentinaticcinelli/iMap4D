function [smoothingpic] = select_smoothing4D(handles,categorical_conditions_default,continuous_conditions,categorical_conditions,continuous_conditions_default)
%%
% initial visual degree for smoothing - 1 degree of visual angle
% Last modified: 18/05/2019 by Valentina Ticcinelli
% valentina.ticcinelli@unifr.ch


smoothing_value = 1;


% initial subject and trial for display
is = 1;
it = 1;


nPoints=handles.nPoints_resampled; %for each dimension
smoothingpic  = 3;

% make 3d gaussian
gaussienne=gauss3d(nPoints,smoothingpic);



% 
% % % % screen_y_pixel       = str2double(handles.xy_size{2});
% % % % user_visual_angle    = smoothing_value/(2*sqrt(log(2))); % in pixel. we have this parameter smtpl=sqrt(2)*sigma and sigma=FWHM/(2*sqrt(2*log(2))) and smtpl=FWHM/(2*sqrt(log(2)))
% % % % distance_y_cm        = str2double(handles.xy_size(6));
% % % % participant_distance = str2double(handles.xy_size(7));
% % % 
% % % % smoothingpic         = round(user_visual_angle/(atan(distance_y_cm /2/participant_distance)/pi*180)*(screen_y_pixel/2));
% % % % 
% % % % xSize      = str2double(handles.xy_size{3});
% % % % ySize      = str2double(handles.xy_size{4});
% % % 
% % % % 
% % % % 
% % % % [x, y]     = meshgrid(-floor(xSize/2)+.5:floor(xSize/2)-.5, -floor(ySize/2)+.5:floor(ySize/2)-.5);
% % % % 
% % % % gaussienne = exp(- (x .^2 / smoothingpic ^2) - (y .^2 / smoothingpic ^2));
% % % % gaussienne = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));
% % % % % f_fil = fft2(gaussienne);
%gaussienne = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));





%find the unique subjects
subject = handles.data(:,categorical_conditions_default.idx_categorical_default(1));
[subjlist,ia,idx]= unique(subject);

if iscell(subjlist)==1
    idx = strcmpi(subject,subjlist{is});
else
    idx = subject==subjlist(is);
end

data_separated = handles.data(idx,:);

trial = data_separated(:,categorical_conditions_default.idx_categorical_default(2));
selected_conditions = [continuous_conditions.idx_continuous;categorical_conditions.idx_categorical]; %detect the predictors
tbl = [trial,data_separated(:,selected_conditions)];

% Transform the data into double for continuous variable
if iscellstr(data_separated(:,continuous_conditions_default.idx_continuous_default(1)))==1
    seyex = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(1)));
    seyey = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(2)));   % retrieve the input eye_y of the user
    seyez = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(3)));   % retrieve the input eye_y of the user
    sfixd = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(4)));   % retrieve the input fix_d of the user
    if handles.mapType==2
       sfixd=0*sfixd+1;
    end
else
    seyex = data_separated(:,continuous_conditions_default.idx_continuous_default(1));    % retrieve the input eye_x of the user
    seyey = data_separated(:,continuous_conditions_default.idx_continuous_default(2));  
    seyez = data_separated(:,continuous_conditions_default.idx_continuous_default(3)); % retrieve the input eye_y of the user
    sfixd = data_separated(:,continuous_conditions_default.idx_continuous_default(4));   % retrieve the input fix_d of the user
    if handles.mapType==2
       sfixd=0*sfixd+1;
    end
end

%find the unique trials
if iscellstr(tbl(:,1))==1
    [~,trialstend,t3]= unique(str2double(tbl(:,1)),'stable');
else
    [~,trialstend,t3]= unique(tbl(:,1),'stable');
end
trialstend(:,2) = [trialstend(2:end,1)-1;length(t3)];

% fixation matrix
seyext = seyex(trialstend(it,1):trialstend(it,2));
seyeyt = seyey(trialstend(it,1):trialstend(it,2));
seyezt = seyez(trialstend(it,1):trialstend(it,2));
intv   = sfixd(trialstend(it,1):trialstend(it,2));

% 
if handles.mapType==2
    intv=ones(size(intv));
end

% 
% coordX    = round(seyeyt);%switch matrix coordinate here
% coordY    = round(seyext);
% coordZ    = round(seyezt);

indV = dsearchn(handles.obj.v, [seyext seyeyt seyezt]);

%% part from my code
% transform obj into a linear space
[spaceObj,indLinPointsInSpace] =linObjgen(handles.obj,nPoints,indV,intv);


% pass to FFT and filter
f_obj          = fftn(spaceObj); 
filtered_mat=gaussienne.*f_obj;
smoothpic      = abs(fftshift(ifftn(filtered_mat)));%/sqrt(smoothingpic);

valFilt=[];
% get the color for each vertices from the inverse transformed 3D map
for i=1:length(indLinPointsInSpace)
    valFilt(i)=smoothpic(indLinPointsInSpace(i,1),indLinPointsInSpace(i,2),indLinPointsInSpace(i,3));
end
%%

c=parula(128);
maxScaleMap=max(valFilt);
minScaleMap=min(valFilt);

% maxScaleVal=max(intv);
% minScaleVal=min(intv);


nCol=length(c);
indC=ceil(intv*nCol/maxScaleMap);




% indx1     = coordX>0 & coordY>0 & coordX<ySize & coordY<xSize;
% rawmap    = full(sparse(coordX(indx1), coordY(indx1), intv(indx1), ySize, xSize));
% smoothpic = conv2(rawmap, gaussienne,'same');

%'menubar','none','resize','off',
S.fh = figure('NumberTitle','off','Name','Smoothing','position',[100 100 900 500]);

subplot(5,6,[1 2 3 7 8 9 13 14 15 19 20 21 25 26 27])
%spy(sparse(rawmap),8);
colormap(parula)
if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on
scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')
cb=colorbar;
cb.Position=[0.49 0.482 0.023 0.217];
caxis([minScaleMap maxScaleMap])
view ([180 -60])
axis('equal','off')

subplot(5,6,[4 5 6 10 11 12 16 17 18 22 23 24 28 29 30])

if isfield(handles.obj,'f4')
patch('vertices', handles.obj.v, 'faces', handles.obj.f4,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield(handles.obj,'f3')
patch('vertices', handles.obj.v, 'faces', handles.obj.f3,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Smoothed 3D map sm=3, np=30')
xlabel('x'); ylabel('y'); zlabel('z')
%colorbar
caxis([minScaleMap maxScaleMap])
view ([180 -60])


%imagesc(smoothpic)
axis('equal','off')

sz_pshb1 = [60,15];

S.text_title1 = uicontrol('style','text',...
    'units','pix',...
    'position',[150 420 250 20],...
    'string',['Subject:' num2str(is) ', Trial:' num2str(it)],...
    'HorizontalAlignment','center','Fontweight','Bold','Background','White');

S.text_title2 = uicontrol('style','text',...
    'units','pix',...
    'position',[490 420 280 20],...
    'string',['Smoothing at ' num2str(smoothing_value) ' degree of Visual Angle'],...
    'HorizontalAlignment','center','Fontweight','Bold','Background','White');

set(gcf,'color','w'); % white background

scale_string = {'Adjust the smoothing parameter or press done'};
S.text_1 = uicontrol('style','text',...
    'units','pix',...
    'position',[520 85 500 30],...
    'string',scale_string  ,... %imagesc(squeeze(mean(handles.FixMap_estimated,1)));axis('equal','off')
    'HorizontalAlignment','left','Fontweight','Bold','Background','White');

S.text = uicontrol('style','text',...
    'units','pix',...
    'position',[520 65 150 15],...
    'string','Smoothing parameter in pixel: ',...
    'HorizontalAlignment','left','Fontweight','Bold','Background','White');

% create push button to validate the smoothing value
uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Validate','position',[770 65 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@validate);

% create push button to validate the smoothing value
uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Done','position',[770 40 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@done);

S.edit = uicontrol('style','edit',...
    'unit','pix','string',smoothingpic,'backgroundcolor','white','position',[680 65 sz_pshb1(1) sz_pshb1(2)]);

S.text_3 = uicontrol('style','text',...
    'units','pix',...
    'position',[120 60 250 30],...
    'string','Visualize another subject/Trial',...
    'HorizontalAlignment','left','Fontweight','Bold','Background','White');

% create push button to validate the smoothing value
uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Generate','position',[350 75 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@validate2);

uiwait(gcf)
%%
% local callback functions
    function validate(hObject,eventdata)
        
        uiresume(gcf)
        smoothingpic = str2double(get(S.edit,'string'));
        gaussienne=gauss3d(nPoints,smoothingpic);

% 
%         
%         gaussienne = exp(- (x .^2 / smoothingpic ^2) - (y .^2 / smoothingpic ^2));
%         gaussienne = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));
%         f_fil = fft2(gaussienne);
%         
%         f_mat = fft2(rawmap); % 2D fourrier transform on the points matrix
%         filtered_mat = f_mat .* f_fil;
%         smoothpic = real(fftshift(ifft2(filtered_mat)));
filtered_mat=gaussienne.*f_obj;
smoothpic      = abs(fftshift(ifftn(filtered_mat)));%/sqrt(smoothingpic);

   %     smoothpic = conv2(rawmap, gaussienne,'same');
        smoothing_value=smoothingpic%/(screen_y_pixel/2)*(atan(distance_y_cm /2/participant_distance)/pi*180)*2;
       
        valFilt=[];
        
for i=1:length(indLinPointsInSpace)
    valFilt(i)=smoothpic(indLinPointsInSpace(i,1),indLinPointsInSpace(i,2),indLinPointsInSpace(i,3));
end
     c=parula(128);
maxScaleMap=max(valFilt);
minScaleMap=min(valFilt);

% maxScaleVal=max(intv);
% minScaleVal=min(intv);


nCol=length(c);
indC=ceil(intv*nCol/maxScaleMap);   %
        
subplot(5,6,[ 4 5 6 10 11 12 16 17 18 22 23 24 28 29 30])
        
        
if isfield(handles.obj,'f4')
patch('vertices', handles.obj.v, 'faces', handles.obj.f4,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield(handles.obj,'f3')
patch('vertices', handles.obj.v, 'faces', handles.obj.f3,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Smoothed 3D map sm=3, np=30')
xlabel('x'); ylabel('y'); zlabel('z')

caxis([minScaleMap maxScaleMap])
view ([180 -60])



      %  imagesc(smoothpic)
        axis('equal','off')
        
        S.text_title2 = uicontrol('style','text',...
            'units','pix',...
            'position',[490 420 280 20],...
            'string',['Smoothing at ' num2str(smoothing_value) ' degree of Visual Angle'],...
            'HorizontalAlignment','center','Fontweight','Bold','Background','White');
        
        
        uiwait(gcf)
    end

    function validate2(hObject,eventdata)
        
        uiresume(gcf)
        is=randi(length(subjlist));
        if iscell(subjlist)==1
            idx = strcmpi(subject,subjlist{is});
        else
            idx = subject==subjlist(is);
        end
        data_separated = handles.data(idx,:);
        
        trial = data_separated(:,categorical_conditions_default.idx_categorical_default(2));
        selected_conditions = [continuous_conditions.idx_continuous;categorical_conditions.idx_categorical]; %detect the predictors
        tbl = [trial,data_separated(:,selected_conditions)];
        
        % Transform the data into double for continuous variable
        if iscellstr(data_separated(:,continuous_conditions_default.idx_continuous_default(1)))==1
            seyex = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(1)));
            seyey = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(2)));   % retrieve the input eye_y of the user
            seyez = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(3)));   % retrieve the input eye_y of the user
            sfixd = str2double(data_separated(:,continuous_conditions_default.idx_continuous_default(4)));   % retrieve the input fix_d of the user
        else
            seyex = data_separated(:,continuous_conditions_default.idx_continuous_default(1));    % retrieve the input eye_x of the user
            seyey = data_separated(:,continuous_conditions_default.idx_continuous_default(2));   % retrieve the input eye_y of the user
            seyez = data_separated(:,continuous_conditions_default.idx_continuous_default(3));   % retrieve the input eye_y of the user
            sfixd = data_separated(:,continuous_conditions_default.idx_continuous_default(4));   % retrieve the input fix_d of the user
        end
        
        %find the unique trials
        if iscellstr(tbl(:,1))==1
            [~,trialstend,t3]= unique(str2double(tbl(:,1)),'stable');
        else
            [~,trialstend,t3]= unique(tbl(:,1),'stable');
        end
        trialstend(:,2)=[trialstend(2:end,1)-1;length(t3)];
        it=randi(size(trialstend,1));
        
        % fixation matrix
        seyext=seyex(trialstend(it,1):trialstend(it,2));
        seyeyt=seyey(trialstend(it,1):trialstend(it,2));
        seyezt=seyez(trialstend(it,1):trialstend(it,2));
        intv=sfixd(trialstend(it,1):trialstend(it,2));
        if handles.mapType==2
            intv=ones(size(intv));
        end


        indV = dsearchn(handles.obj.v, [seyext seyeyt seyezt]);

        %% part from my code
        % transform obj into a linear space
        [spaceObj,indLinPointsInSpace] =linObjgen(handles.obj,nPoints,indV,intv);


        % pass to FFT and filter
        f_obj          = fftn(spaceObj); 
        filtered_mat=gaussienne.*f_obj;
        smoothpic      = abs(fftshift(ifftn(filtered_mat)));%/sqrt(smoothingpic);

        valFilt=[];
        % get the color for each vertices from the inverse transformed 3D map
        for i=1:length(indLinPointsInSpace)
            valFilt(i)=smoothpic(indLinPointsInSpace(i,1),indLinPointsInSpace(i,2),indLinPointsInSpace(i,3));
        end
%         coordX    = round(seyeyt);%switch matrix coordinate here
%         coordY    = round(seyext);
%         indx1     = coordX>0 & coordY>0 & coordX<ySize & coordY<xSize;
%         rawmap    = full(sparse(coordX(indx1), coordY(indx1), intv(indx1), ySize, xSize));
%         smoothpic = conv2(rawmap, gaussienne,'same');

        c=parula(128);
% maxScaleVal=max(intv);
% minScaleVal=min(intv);
maxScaleMap=max(valFilt);
minScaleMap=min(valFilt);

nCol=length(c);
indC=ceil(intv*nCol/maxScaleMap);
        
        %
subplot(5,6,[1 2 3 7 8 9 13 14 15 19 20 21 25 26 27])
cla
%spy(sparse(rawmap),8);
colormap(parula)
if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on
scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')
cb=colorbar;
cb.Position=[0.49 0.482 0.023 0.217];
caxis([minScaleMap maxScaleMap])
view ([180 -60])
axis('off')
subplot(5,6,[4 5 6 10 11 12 16 17 18 22 23 24 28 29 30])
cla
if isfield(handles.obj,'f4')
patch('vertices', handles.obj.v, 'faces', handles.obj.f4,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield(handles.obj,'f3')
patch('vertices', handles.obj.v, 'faces', handles.obj.f3,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Smoothed 3D map sm=3, np=30')
xlabel('x'); ylabel('y'); zlabel('z')
%colorbar
caxis([minScaleMap maxScaleMap])
view ([180 -60])
axis('equal','off')
        
        S.text_title1 = uicontrol('style','text',...
            'units','pix',...
            'position',[140 420 250 20],...
            'string',['Subject:' num2str(is) ', Trial:' num2str(it)],...
            'HorizontalAlignment','center','Fontweight','Bold','Background','White');
        
        uiwait(gcf)
    end

%---------------------------------------------------------------
    function done(source,event)
        % get values of checkboxes and extract selected predictors
        uiresume(gcf)
        if ishandle(S.fh)
            delete(S.fh)
        end
    end






end
