function imapLMMdisplay4D(obj,StatMap,normalized,backgroundfile,cmap,colormaprange,distplot,pathname)
% Usage: imapLMMdisplay(StatMap,normalized,backgroundfile,colourmap,colormaprange,distplot,foldername)
% display result after contrast test. Input result from imapLMMcontrast
% input structure format {opt} {Pmap} {Pmask} {F/Tmap} {betamap(optional)}
% {labels of the maps} {MCC related field}
%   display map value would be normalized [1] as default
%   backgroundfile could be image/matrix/[empty]
%   colormap could be predefined
%   output distribution of statistic value (optional, default 0)
%
% opt within StatMap:
% opt.type     - model/fixed/random/model beta/predictor beta
% opt.alpha    - default 0.05
% opt.c        - for coefficients and Catepredictors only, cell array
%               containing contrast vector/matrix
% opt.h        - for coefficients and Catepredictors only, cell array
%               containing hypothesis vector/matrix
% opt.onetail  - option to do onetail test, perform on two tail threshold
%               for convenience (alpha/2)
% opt.name     - for coefficients and Catepredictors only, name of each
%               contrast (for plotting)
% See also imapLMM, imapLMMcontrast
%
% 2015-02-12 Junpeng Lao, University of Fribourg.
%--------------------------------------------------------------------------
% Copyright (C) iMap Team 2015

%%
scrsz=get(0,'ScreenSize');% get screen size for output display
opt=StatMap.opt;
currentdirectory = pwd;
if nargin<2+1
    normalized=1;
end

if nargin<3+1
    im3D=[];
else %read background map.
    if ischar(backgroundfile)&&~isempty(backgroundfile)
        imbackground = double(imread(sprintf(backgroundfile)))/255;
    elseif isempty(backgroundfile)
        im3D=[];
        imbackground = [];
    else
        imbackground = double(backgroundfile)/max(double(backgroundfile(:)));
    end
    if ~isempty(imbackground)
        % transfer background image to gray scale
        if size(imbackground,3)>1
            im3D = repmat(rgb2gray(imbackground),[1,1,3]);
        else
            im3D = repmat(imbackground,[1,1,3]);
        end
    end
end

if nargin<4+1 || isempty(cmap)
    darkness=0.75;
    colourmap(:,1)=[linspace(0,1,32) linspace(1,darkness,32)];
    colourmap(:,2)=[linspace(0,1,32) linspace(1,0,32)];
    colourmap(:,3)=[linspace(darkness,1,32) linspace(1,0,32)];
elseif ischar(cmap)&& ~isempty(cmap)
    cmap2=colormap(cmap);
    colourmap=cmap2;
end

if nargin<5+1 || isempty(colormaprange) || isnan(colormaprange)
    colormaprange=1;
end

if nargin<6+1 || isempty(distplot) || isnan(distplot)
    distplot=0;
end

%%if nargin<7+1
    foldername=[pathname '/imapLMMoutput-' opt.type];
%end

if ~exist(foldername, 'dir')
    mkdir(foldername);
end

label=StatMap.label;
maptemp=StatMap.map;
if ~ismatrix(maptemp)
    mask=~isnan(squeeze(sum(maptemp,1)));
else
    mask=~isnan(maptemp);
end
    mask=mask(1,:);
cr=colormaprange;
switch opt.type
    case 'model'% output model fitting and criterion map
        
        %% Rsquared
        figure('NumberTitle','off','Name','R^2 of model','Position',[1 1 scrsz(3) scrsz(4)/2]);
        maprangetmp=sort(squeeze(max(abs(maptemp(1:2,mask)))));
        mapmax=maprangetmp(round(length(maprangetmp)*cr));
        mapmin=min(min(min(maptemp(1:2,mask))));
        range1=[-mapmax mapmax];
        range2=[mapmin mapmax];
        for ip=1:2
            subplot(1,2,ip)
            toimage=squeeze(maptemp(ip,:,:));
            %toimage(isnan(toimage)==1)=0;
            heatmapObj4D(obj,toimage)
            %imshow(toimage,range1,'colormap',colourmap);
            h=colorbar;
            caxis(range1);
            set(h,'ylim',range2)
            colormap(colourmap)
            % axis off
            set(gca,'XTick',[],'YTick',[])
            title(label{ip})
        end
        cd(foldername);
        print('-depsc2','-r300','R^2 of model');
        cd(currentdirectory);
        % Model Criterion
        
        figure('NumberTitle','off','Name','Model Criterion','Position',scrsz);
        for ip=1:4
            toimage=squeeze(maptemp(ip+2,:,:));
            % mapabs=max(abs(toimage(:)));
            mapmax=max(toimage(:));
            mapmin=min(toimage(:));
            range2=[mapmin mapmax];
            subplot(2,2,ip)
            %if mapmin>0
              %  toimage(isnan(toimage)==1)=0; %%it was inf 
            %end
            heatmapObj4D(obj,toimage)
            %imshow(toimage,range1,'colormap',colourmap);
            h=colorbar;          
            colormap(colourmap)
            caxis(range1);
            set(h,'ylim',range2)
            %imshow(toimage,range2,'colormap',colourmap);
            %h=colorbar;set(h,'ylim',range2)
            % axis off
            set(gca,'XTick',[],'YTick',[])
            title(label{ip+2})
        end
        cd([foldername]);
        print('-depsc2','-r300','Model Criterion');
        cd(currentdirectory);
        
% % %         if ~isempty(im3D)
% % %             im3D2=imresize(im3D,[size(maptemp,2),size(maptemp,3)],'nearest');
% % %             % Rsquared
% % %             figure('NumberTitle','off','Name','R^2 of model(with background)','Position',[1 1 scrsz(3) scrsz(4)/2]);
% % %             maprangetmp=sort(squeeze(max(abs(maptemp(1:2,mask)))));
% % %             mapmax=maprangetmp(round(length(maprangetmp)*cr));
% % %             mapmin=min(min(min(maptemp(1:2,mask))));
% % %             range1=[-mapmax mapmax];
% % %             range2=[mapmin mapmax];
% % %             for ip=1:2
% % %                 subplot(1,2,ip)
% % %                 toimage=squeeze(maptemp(ip,:,:));
% % %                 toimage(isnan(toimage)==1)=0;
% % %                 toimagergb=indtorgb(toimage,range1(1),range1(2),colourmap);
% % %                 toimage=toimagergb.*0.7+im3D2.*0.3;
% % %                 imshow(toimage,range1);
% % %                 % axis off
% % %                 set(gca,'XTick',[],'YTick',[])
% % %                 title(label{ip})
% % %             end
% % %             cd(['./' foldername]);print('-depsc2','-r300','R^2 of model(with background)');cd('..');
% % %             % Model Criterion
% % %             figure('NumberTitle','off','Name','Model Criterion(with background)','Position',scrsz);
% % %             for ip=1:4
% % %                 toimage=squeeze(maptemp(ip+2,:,:));
% % %                 % mapabs=max(abs(toimage(:)));
% % %                 mapmax=max(toimage(:));
% % %                 mapmin=min(toimage(:));
% % %                 range2=[mapmin mapmax];
% % %                 subplot(2,2,ip)
% % %                 if mapmax<0
% % %                     toimage(isnan(toimage)==1)=mapmin;
% % %                 else
% % %                     toimage(isnan(toimage)==1)=mapmax;
% % %                 end
% % %                 toimagergb=indtorgb(toimage,range2(1),range2(2),colourmap);
% % %                 toimage=toimagergb.*0.7+im3D2.*0.3;
% % %                 imshow(toimage,range2);
% % %                 % axis off
% % %                 set(gca,'XTick',[],'YTick',[])
% % %                 title(label{ip+2})
% % %             end
% % %             cd(['./' foldername]);print('-depsc2','-r300','Model Criterion(with background)');cd('..');
% % %         end
        
    case 'fixed'% output Fvalue map and mask according to MCC
        %%
        % pmptemp=StatMap.Pmap;
        msktemp=StatMap.Pmask;
        % output Statvalue map, Statvalue map with P<0.05 and Statvalue map
        % with mask
        
        maprangetmp=sort(maptemp(~isnan(maptemp(:))));
        mapmax=maprangetmp(round(length(maprangetmp)*cr));
        % mapmax=max(maptemp(:));
        % mapmin=min(maptemp(:));
%         if ~isempty(im3D)
%             im3D2=imresize(im3D,[size(maptemp,2),size(maptemp,3)],'nearest');
%         end
        for ip=1:length(label)
            toimage=squeeze(maptemp(ip,:,:));
            toimage_nan=toimage;
            toimage(isnan(toimage)==1)=0;
            % pvaltmp=squeeze(pmptemp(ip,:,:));
            masktmp=squeeze(msktemp(ip,:,:));
            if sum(masktmp(:))==0
                warning('No significant result from the current condition...')
            else
                figure('NumberTitle','off','Name',label{ip},'Position',[1 1 scrsz(3) scrsz(4)/2]);
                
                maprangetmp1=sort(toimage(:));
                mapmax1=maprangetmp1(round(length(maprangetmp1)*cr));
                % mapmax1=max(toimage(:));
                mapmin1=min(toimage(:));
                range2=[mapmin1 mapmax1];
                if normalized==1
                    range1=[0 mapmax];
                else
                    range1=[0 mapmax1];
                end
                subplot(1,2,1);
                
                heatmapObj4D(obj,toimage_nan)
                h=colorbar;          
                colormap(colourmap)
                caxis(range1);
                set(h,'ylim',range2)
%                 imshow(toimage,range1,'colormap',colourmap);
%                 h=colorbar;set(h,'ylim',range2)
                % axis off
                set(gca,'XTick',[],'YTick',[])
                title('Statistic value map')
                
                subplot(1,2,2);
                toimage2=toimage;
                %
                %toimage2(bwperim(masktmp))=NaN;
                toimagesg=indtorgb(toimage2,range1(1),range1(2),colourmap);
                toimagesg(toimagesg==range1(1))=NaN;
                heatmapObj4D(obj,NaN*toimage_nan);
                hold on
                scatter3(obj.v(:,1),obj.v(:,2),obj.v(:,3),30,squeeze(toimagesg),'filled','MarkerEdgeColor','none')
                h=colorbar;      
                caxis(range1);
                colormap(colourmap)
                set(h,'ylim',range2)
                
                % imshow(toimagesg)
                set(gca,'XTick',[],'YTick',[])
                title('Significant vertices marked by circles')
                cd([foldername]);
                print('-depsc2','-r300',genvarname(label{ip}));
                cd(currentdirectory);
                
%                 if ~isempty(im3D)
%                     figure('NumberTitle','off','Name',[label{ip} '(with background)'] ,'Position',[1 1 scrsz(3) scrsz(4)/2]);
%                     subplot(1,2,1);
%                     toimagergb=indtorgb(toimage2,range1(1),range1(2),colourmap);
%                     toimagebg=toimagergb.*0.7+im3D2.*0.3;
%                     imshow(toimagebg,range1);
%                     % axis off
%                     set(gca,'XTick',[],'YTick',[])
%                     title('Statistic value map')
%                     subplot(1,2,2);
%                     hc=imagesc(im3D2,range1);set(hc,'AlphaData',0.25);axis equal;
%                     hold on;
%                     toimage2(~masktmp)=NaN;
%                     contv=linspace(min(toimage2(:)),max(toimage2(:)),6);
%                     if isfinite(contv)
%                         imcontour(toimage2,contv);colorbar;caxis([0 range1(end)])
%                     end
%                     imcontour(1:size(masktmp,2),1:size(masktmp,1),masktmp,1,'k','LineWidth',1);
%                     set(gca,'XTick',[],'YTick',[])
%                     title('Significant area marked by dark line')
%                     cd(['./' foldername]);print('-depsc2','-r300',[genvarname(label{ip}) '(with background)']);cd('..');
%                 end
            end
        end
        
    case 'random'% output Fvalue map, beta map and mask according to MCC
        %% 
        % pmptemp=StatMap.Pmap;
        msktemp=StatMap.Pmask;
        % output Statvalue map, Statvalue map with P<0.05 and Statvalue map
        % with mask
        maprangetmp=sort(maptemp(~isnan(maptemp(:))));
        mapmax=maprangetmp(round(length(maprangetmp)*cr));
        mapmin=min(maptemp(:));
        for ip=1:length(label)
            toimage=squeeze(maptemp(ip,:,:));
            toimage(isnan(toimage)==1)=0;
            % pvaltmp=squeeze(pmptemp(ip,:,:));
            masktmp=squeeze(msktemp(ip,:,:));
            if sum(masktmp(:))==0
                warning('No significant result from the current condition...')
            else
                h1=figure('NumberTitle','off','Name',[label{ip} ' tvalue map'],'Position',[1 1 scrsz(3) scrsz(4)/2]);
                
                maprangetmp1=sort(toimage(:));
                mapmax1=maprangetmp1(round(length(maprangetmp1)*cr));
                % mapmax1=max(toimage(:));
                mapmin1=min(toimage(:));
                range2=[mapmin1 mapmax1];
                if normalized==1
                    range1=[mapmin mapmax];
                else
                    range1=[-mapmax1 mapmax1];
                end
                toimage2=toimage;
                toimage2(toimage2==range1(1))=NaN;
                %toimage2(bwperim(masktmp))=0;
                % toimagesg=indtorgb(toimage2,range1(1),range1(2),colourmap);
                %%%%%%%%%%%%imshow(toimage2,range1,'colormap',colourmap)    
                heatmapObj4D(obj,toimage2);
                hold on
                h=colorbar;          
                colormap(colourmap)
                caxis(range1);
                set(h,'ylim',range2)              
%                 
%                 h=colorbar;set(h,'ylim',range2)
                set(gca,'XTick',[],'YTick',[])
                title('Significant area marked by white line')
                cd([ foldername]);
                print('-dpng','-r300',genvarname(label{ip}));
                cd(currentdirectory);
            end
        end
        
    case {'predictor beta', 'model beta'} % output F/Tvalue map, beta map, pvalue map, and mask according to MCC
        %% 
        betatmp=StatMap.beta;
        % pmptemp=StatMap.Pmap;
        msktemp=StatMap.Pmask;
        % output Statvalue map, Statvalue map with P<0.05 and Statvalue map
        % with mask
        maprangetmp=sort(maptemp(~isnan(maptemp(:))));
        mapmax=maprangetmp(round(length(maprangetmp)*cr));
        % mapmin=min(maptemp(:));
        mapmaxb=max(abs(betatmp(:)));
%         if ~isempty(im3D)
%             im3D2=imresize(im3D,[size(maptemp,2),size(maptemp,3)],'nearest');
%         end
        for ip=1:length(label)
            toimage=squeeze(maptemp(ip,:,:));
            toimage_nan=toimage;
            toimage(isnan(toimage)==1)=0;
            
            toimagebeta=squeeze(betatmp(ip,:,:));
            toimagebeta(isnan(toimagebeta)==1)=0;
            % pvaltmp=squeeze(pmptemp(ip,:,:));
            masktmp=squeeze(msktemp(ip,:,:));
            if sum(masktmp(:))==0
                warning('No significant result from the current condition...')
            else
                figure('NumberTitle','off','Name',label{ip},'Position',scrsz);
                maprangetmp1=sort(toimage(:));
                mapmax1=maprangetmp1(round(length(maprangetmp1)*cr));
                mapmin1=min(toimage(:));
                range2=[mapmin1 mapmax1];
                mapmax1beta=max(toimagebeta(:));
                mapmin1beta=min(toimagebeta(:));
                range2beta=[mapmin1beta mapmax1beta];
                if normalized==1
                    range1=[0 mapmax];
                    range1beta=[-mapmaxb mapmaxb];
                else
                    range1=[0 mapmax1];
                    range1beta=[-max(abs(toimagebeta(:))) max(abs(toimagebeta(:)))];
                end
                
                subplot(2,2,1);
                toimage(toimage==range1(1))=NaN;
                heatmapObj4D(obj,toimage);
                hold on
                h=colorbar;          
                colormap(colourmap)
                caxis(range1);
                set(h,'ylim',range2)  
% %                 imshow(toimage,range1,'colormap',colourmap);
% %                 h=colorbar;set(h,'ylim',range2)
% %                 % axis off
                set(gca,'XTick',[],'YTick',[])
                title('Statistic value map')
                
                if nansum(toimagebeta(:))~=0
                    subplot(2,2,3);
                  %  imshow(toimagebeta,range1beta,'colormap',colourmap);
                   % h=colorbar;set(h,'ylim',range2beta)
                                   toimagebeta(toimagebeta==range1(1))=NaN;
                heatmapObj4D(obj,toimagebeta);
                hold on
                h=colorbar;          
                colormap(colourmap)
                caxis(range1);
                set(h,'ylim',range2)  
                    % axis off
                    set(gca,'XTick',[],'YTick',[])
                    title('Beta map')
                end
                
                subplot(2,2,2);
                toimage2=toimage;
                %toimage2(bwperim(masktmp))=NaN;

                toimagesg=indtorgb(toimage2,range1(1),range1(2),colourmap);
                toimagesg(toimagesg==range1(1))=NaN;
                                
                heatmapObj4D(obj,NaN*toimage_nan);
                hold on
                scatter3(obj.v(:,1),obj.v(:,2),obj.v(:,3),30,squeeze(toimagesg),'filled','MarkerEdgeColor','none')
                h=colorbar;      
                caxis(range1);
                colormap(colourmap)
                set(h,'ylim',range2)
                
                %imshow(toimagesg)
                set(gca,'XTick',[],'YTick',[])
                title('Significant area marked by dark line')
                
                if nansum(toimagebeta(:))~=0
                    subplot(2,2,4);
                    toimage2beta=toimagebeta;
                    
                    %toimage2beta(bwperim(masktmp))=NaN;
                   
                    toimagesgbeta=indtorgb(toimage2beta,range1beta(1),range1beta(2),colourmap);
                    toimagesgbeta(toimagesgbeta==range1(1))=NaN;
                    
                heatmapObj4D(obj,NaN*toimage_nan);
                hold on
                scatter3(obj.v(:,1),obj.v(:,2),obj.v(:,3),30,squeeze(toimagesgbeta),'filled','MarkerEdgeColor','none')
                h=colorbar;      
                caxis(range1);
                colormap(colourmap)
                set(h,'ylim',range2)
                    %imshow(toimagesgbeta)
                    set(gca,'XTick',[],'YTick',[])
                    title('Significant area marked by dark line')
                end
                cd([ foldername]);
                print('-depsc2','-r300',genvarname(label{ip}));
                cd(currentdirectory);
% % %                 if ~isempty(im3D)
% % %                     figure('NumberTitle','off','Name',[label{ip} '(with background)'] ,'Position',scrsz);
% % %                     
% % %                     subplot(2,2,1);
% % %                     toimagergb=indtorgb(toimage2,range1(1),range1(2),colourmap);
% % %                     toimagebg=toimagergb.*0.7+im3D2.*0.3;
% % %                     imshow(toimagebg,range1);
% % %                     axis off
% % %                     set(gca,'XTick',[],'YTick',[])
% % %                     title('Statistic value map')
% % %                     if nansum(toimagebeta(:))~=0
% % %                         subplot(2,2,3);
% % %                         toimagebgbeta=toimagesgbeta.*0.7+im3D2.*0.3;
% % %                         imshow(toimagebgbeta,range1beta);
% % %                         axis off
% % %                         set(gca,'XTick',[],'YTick',[])
% % %                         title('Beta map')
% % %                     end
% % %                     subplot(2,2,2)                   
% % %                     hc=imagesc(im3D2,range1);set(hc,'AlphaData',0.25);axis equal;
% % %                     hold on
% % %                     toimage2(~masktmp)=NaN;
% % %                     contv=linspace(min(toimage2(:)),max(toimage2(:)),6);
% % %                     if isfinite(contv)
% % %                         imcontour(toimage2,contv);colorbar;caxis([0 range1(end)])
% % %                     end
% % %                     imcontour(1:size(masktmp,2),1:size(masktmp,1),masktmp,1,'k','LineWidth',1)                    
% % %                     set(gca,'XTick',[],'YTick',[])
% % %                     title('Significant area marked by dark line')
% % %                     if nansum(toimagebeta(:))~=0
% % %                         subplot(2,2,4)
% % %                         hc=imagesc(im3D2,range1);set(hc,'AlphaData',0.25);axis equal;
% % %                         hold on
% % %                         toimage2beta(~masktmp)=NaN;
% % %                         contv=linspace(min(toimage2beta(:)),max(toimage2beta(:)),6);
% % %                         if isfinite(contv)
% % %                             imcontour(toimage2beta,contv);colorbar;caxis([0 range1beta(end)])
% % %                         end
% % %                         imcontour(1:size(masktmp,2),1:size(masktmp,1),masktmp,1,'k','LineWidth',1);
% % %                         set(gca,'XTick',[],'YTick',[])
% % %                         title('Significant area marked by dark line')
% % %                     end
% % %                     cd([foldername]);
% % %                     print('-depsc2','-r300',[genvarname(label{ip}) '(with background)']);
% % %                     cd(currentdirectory);
% % %                 end
            end
        end
end
%%

if distplot~=0
    subpy=floor(sqrt(length(label)));
    subpx=ceil(sqrt(length(label)));
    if subpy*subpx<length(label);subpy=subpx;end;
    figure('NumberTitle','off','Name','Stat value distribution','Position',scrsz);
    for ip=1:length(label)
        tmp=squeeze(maptemp(ip,:));
        y = tmp(isnan(tmp)==0);
        x = linspace(min(y),max(y),200);
        subplot(subpy,subpx,ip)
        hist(y,x);
        % Get histogram patches
        ph = get(gca,'children');
        % Determine number of histogram patches
        N_patches = length(ph);
        for i = 1:N_patches
            % Get patch vertices
            vn = get(ph(i),'Vertices');
            % Adjust y location
            vn(:,2) = vn(:,2) + 1;
            % Reset data
            set(ph(i),'Vertices',vn)
        end
        set(gca,'yscale','log');% Change scale
        title(label{ip})
    end
    cd([ foldername]);
    print('-depsc2','-r300','Map value distribution');
    cd(currentdirectory);
    if isfield(StatMap,'beta')==1
        figure('NumberTitle','off','Name','Beta value distribution','Position',scrsz);
        for ip=1:length(label)
            tmp=squeeze(maptemp(ip,:));
            y = tmp(isnan(tmp)==0);
            x = linspace(min(y),max(y),200);
            subplot(subpy,subpx,ip)
            hist(y,x);
            % Get histogram patches
            ph = get(gca,'children');
            % Determine number of histogram patches
            N_patches = length(ph);
            for i = 1:N_patches
                % Get patch vertices
                vn = get(ph(i),'Vertices');
                % Adjust y location
                vn(:,2) = vn(:,2) + 1;
                % Reset data
                set(ph(i),'Vertices',vn)
            end
            set(gca,'yscale','log');% Change scale
            title(label{ip})
        end
        cd([ foldername]);
        print('-depsc2','-r300','Beta value distribution');
        cd(currentdirectory);
    end
end
