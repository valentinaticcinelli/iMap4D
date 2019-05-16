function [f_fil,gaussienne]=gauss3d(nPoints,smoothingpic)
% nPoints=30; %for each dimension
% smoothingpic   = 6;

xSizeG = nPoints;
ySizeG = nPoints;
zSizeG = nPoints;

[xm, ym, zm]         = meshgrid(-floor(ySizeG/2)+.5:floor(ySizeG/2)-.5, -floor(xSizeG/2)+.5:floor(xSizeG/2)-.5,-floor(zSizeG/2)+.5:floor(zSizeG/2)-.5);
gaussienne     = exp(- (xm .^2 / smoothingpic ^2) - (ym .^2 / smoothingpic ^2)- (zm .^2 / smoothingpic ^2));
gaussienne     = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));
f_fil          = fftn(gaussienne); 
end


