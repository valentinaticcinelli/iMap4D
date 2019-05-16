function idx = modelling_analysis4D()
idx = 1;
[filename, pathname] = uigetfile('*.mat','MultiSelect','on',' Select FixMap, Mask and PredictorM to proceed for modelling');
fullpathname = strcat(pathname,filename);
if isempty(fullpathname)
    errordlg('No selected files')
    idx = 0;
    % uiwait (gcf)
end

if (iscell (filename)&& idx==1)
    %loading Fixmap,Mask,Predictors
    h = waitbar(0,'Please wait loading files is in progress','Name','Loading files','color','w');
    
    for i = 1:length(filename)
        load(strcat(pathname,filename{i}))
        waitbar(i/length(filename));
    end
    if ishandle(h) % if the user did not close the wait bar menu
        delete(h)
    end
    if exist('FixMap','var') && exist('PredictorM','var') && exist('Mask','var')
        if sum(Mask(:))<(length(Mask)/100)
            h=figure;
            heatmapObj4D(obj,ones(length(obj.v),1))
            hold on
            scatter3(obj.v(:,1),obj.v(:,2),obj.v(:,3),30,[1 0 0],'filled','MarkerEdgeColor','k');
           % imagesc(Mask)
            answer_user=questdlg('The mask seems to be too small, are you sure you would like to continue?','Warning','yes','no','no');
            close(h);
            if strcmp(answer_user,'no')
                idx = 0;
            end
        end
        if idx==1
            [formula,opt,opttext] = select_condition_model(PredictorM,filename{1});
            if isempty(formula)==0
            [LMMmap,~]=imapLMM4D(FixMap,PredictorM,Mask,opt,formula,opttext{:});
            
            %save LMMmap and lmexample in the folder
            save_LMM(LMMmap,pathname)
            else
                h = warndlg('Window is closed, LMMmap is not calculated');
                set(h,'color','white');
                uiwait(gcf)
                idx = 0;
            end
        end
    else
        h = errordlg('The following variables: FixMap, PredictorM and Mask are mandatory to run the model');
        set(h,'color','white');
        idx = 0;
        uiwait(gcf)
    end
end
