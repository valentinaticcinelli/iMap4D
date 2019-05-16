function [] =heatmapObj4D(obj,valFilt)

if isfield(obj,'f4')
patch('vertices', obj.v, 'faces', obj.f4,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
if isfield(obj,'f3')
patch('vertices', obj.v, 'faces', obj.f3,'FaceVertexCData',valFilt','FaceColor','interp','EdgeAlpha',[0.2]);
end
hold on

%scatter3(handles.obj.v(indV,1),handles.obj.v(indV,2),handles.obj.v(indV,3),30,c(indC,:),'filled','MarkerEdgeColor','k');
%title('Smoothed 3D map sm=3, np=30')
xlabel('x'); ylabel('y'); zlabel('z')
%colorbar
if ~isnan(min(valFilt(:))) && min(valFilt(:))< max(valFilt(:))
caxis([min(valFilt(:)) max(valFilt(:))])
end
view ([180 -60])
axis('equal','off')