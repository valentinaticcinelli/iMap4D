function [answer,Mask,fixthres] = select_mask_parameter4D(FixMap,Mask,handles)
answer = [];
fixthres=handles.fixthres;
 % This line is removed because if we have a small threshold 0.0025 for
 % example by rounding the number the threshold will be considered as 0!
% fixthres = round(fixthres*100)/100;
size_figure = [600,300];
%'menubar','none','resize','off',
S.fh = figure('NumberTitle','off','Name','mean fixation bias and the correspondent mask','position',[300 200 size_figure(1) size_figure(2)]);

c=parula(128);
maxScaleVal=max(mean(FixMap,1));
minScaleVal=min(mean(FixMap,1));
nCol=length(c);
indC=ceil(mean(FixMap,1)*nCol/maxScaleVal);


subplot(5,6,[1 2 3 7 8 9 13 14 15 19 20 21 25 26 27])
%colormap(parula)
if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(:,1),handles.obj.v(:,2),handles.obj.v(:,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')
cb=colorbar;
cb.Position=[0.49 0.482 0.023 0.217];
caxis([minScaleVal maxScaleVal])
view ([180 -60])
axis('equal','off')
%changed this
%%%%%%%%%%%%%%%%%imagesc(squeeze(mean(FixMap,1)));axis('equal','off')
subplot(5,6,[4 5 6 10 11 12 16 17 18 22 23 24 28 29 30])

if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(Mask,1),handles.obj.v(Mask,2),handles.obj.v(Mask,3),30,[1 0 0],'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')

view ([180 -60])
axis('equal','off')

%change this
%%%%%%%%%%%%%%%%%%%%imagesc(Mask);

axis('equal','off')

set(gcf,'color','w'); % white background
scale_string = {'Enter a new threshold to regenerate Mask or press done to continue'};
S.text_1 = uicontrol('style','text',...
    'units','pix',...
    'position',[10 20 590 30],...
    'string',scale_string  ,...imagesc(squeeze(mean(handles.FixMap_estimated,1)));axis('equal','off')
    'HorizontalAlignment','center','Fontweight','Bold','Background','White');
S.text = uicontrol('style','text',...
    'units','pix',...
    'position',[130 10 100 20],...
    'string',' Threshold',...
    'HorizontalAlignment','center');

S.edit = uicontrol('style','edit',...
    'unit','pix','string',num2str(fixthres),'backgroundcolor','white','position',[240 10 60 20]);

% create push button to validate the mask threshold value
sz_pshb1 = [60,20];

uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Validate','position',[310 10 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@validate);

% create push button to validate the mask threshold value
uicontrol('parent',S.fh,'Style','pushbutton','Units','pixel',...
    'String','Done','position',[390 10 sz_pshb1(1) sz_pshb1(2)],...
    'Callback',@done);

uiwait(gcf)


% local callback functions
    function validate(hObject,eventdata)
        
        uiresume(gcf)
        fixthres = str2double(get(S.edit,'string'));
        Mask = squeeze(mean(FixMap,1))>fixthres;
subplot(5,6,[1 2 3 7 8 9 13 14 15 19 20 21 25 26 27])
cla
%colormap(parula)
if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(:,1),handles.obj.v(:,2),handles.obj.v(:,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')
cb=colorbar;
cb.Position=[0.49 0.482 0.023 0.217];
caxis([minScaleVal maxScaleVal])
view ([180 -60])
axis('equal','off')
%changed this
%%%%%%%%%%%%%%%%%imagesc(squeeze(mean(FixMap,1)));axis('equal','off')
subplot(5,6,[4 5 6 10 11 12 16 17 18 22 23 24 28 29 30])
cla
if isfield( handles.obj,'f3')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f3,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield( handles.obj,'f4')
patch('Vertices', handles.obj.v, 'Faces', handles.obj.f4,'FaceVertexCData',ones(length( handles.obj.v),1)*[0.8 0.8 0.8],'FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

scatter3(handles.obj.v(Mask,1),handles.obj.v(Mask,2),handles.obj.v(Mask,3),30,[1 0 0],'filled','MarkerEdgeColor','k');
%title('Single vertices')
xlabel('x'); ylabel('y'); zlabel('z')

view ([180 -60])
axis('equal','off')

%change this
%%%%%%%%%%%%%%%%%%%%imagesc(Mask);

axis('equal','off')
        
        axis('equal','off')
        
        uiwait(gcf)
    end
%---------------------------------------------------------------
    function done(source,event)
        % get values of checkboxes and extract selected predictors
        uiresume(gcf)
        answer = 0;
        if ishandle(S.fh)
            delete(S.fh)
        end
    end
end





