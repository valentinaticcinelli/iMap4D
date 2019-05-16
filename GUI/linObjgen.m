function[spaceObj,indLinPointsInSpace] =linObjgen(obj,nPoints,indV,val)
%generates a 3D matrix with zeros and fixdur values, so that convolutions can be done
%out
%spaceobj=3D matrix of nPoints^3 with zeros and fixdur values
%indLinPointsInSpace=where in 3D (integer within spaceobj) the vertices are
%in
%obj,
%nPoints,
%indV, indices of the obj vertices containing fix points
%val  duration of the fixpoints

spaceLin=zeros(nPoints,3);
N=size(indV,1);
% get limits of dimensions
for i=1:3, limSpace(i,:)=[min(obj.v(:,i)), max(obj.v(:,i))]; end 

% build the linear space there
for i=1:3, spaceLin(:,i)=linspace(limSpace(i,1),limSpace(i,2),nPoints); end

% make the 3D full grid of points for the lin space
counter=0;
pointsLin=zeros(nPoints*nPoints*nPoints,3);
for ix=1:nPoints
    for iy=1:nPoints
        for iz=1:nPoints
            counter=counter+1;
            pointsLin(counter,1)=spaceLin(ix,1);
            pointsLin(counter,2)=spaceLin(iy,2);
            pointsLin(counter,3)=spaceLin(iz,3);
        end
    end
end

% project obj vertices in the linear space
k = dsearchn(pointsLin,obj.v);
linObj=pointsLin(k,:);

% project fixation points in the linear space (destination,origin)
k2 = dsearchn(linObj, obj.v(indV,:));

% get integer indices for fixation points
for i=1:3,indPointsInSpace(:,i)=round((linObj(k2,i)-limSpace(i,1))*(nPoints-1)/(limSpace(i,2)-limSpace(i,1)))+1; end

% make the space object of zeros with values into the corresponding  fixation points
spaceObj=zeros(nPoints,nPoints,nPoints);
for i=1:N, spaceObj(indPointsInSpace(i,1),indPointsInSpace(i,2),indPointsInSpace(i,3))=val(i);end

% get integer indices for obj vertices
for i=1:3,indLinPointsInSpace(:,i)=round((linObj(:,i)-limSpace(i,1))*(nPoints-1)/(limSpace(i,2)-limSpace(i,1)))+1; end

end