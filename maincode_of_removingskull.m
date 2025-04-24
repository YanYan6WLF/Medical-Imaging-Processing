%% main code of removing skull
% in the process, use my function named My_removeskull
clc;clear;
% load data set,the code is only for T2 loder
% if useed for T1 folder, need to change details in code and function
for n = 1:128
    filename = ['IMG',num2str(n,'%04d'),'.DCM'];
    DCM(:,:,n) = dicomread(filename ); 
end

% pre-process
DCM = double(DCM);
for n = 1:128
    DCM(:,:,n) = mat2gray(DCM(:,:,n)); % convert to grayscale
    DCM(:,:,n) = medfilt3(DCM(:,:,n),[3,3,3]); % middle filter
end

% use function to remove skull in xz and yz surface
DCM_xz = My_removeskull(DCM, 'xz', 0.13);
DCM_yz = My_removeskull(DCM, 'yz', 0.13);

% replace some wrong data of DCM_yz with DCM_xz 
for m = 1:60
    DCM_yz(m,:,:) = DCM_xz(m,:,:);
end
for m = 210:256
    DCM_yz(m,:,:) = DCM_xz(m,:,:);
end

volume3D = DCM_yz; % assign for visualization


%% isosurface (code same with "code without removing skull")
% Select an isovalue for isosurface extraction
isovalue = 0.15 * max(volume3D(:)); 

% Extract isosurface
[f, v] = isosurface(volume3D, isovalue);
% use Face-vertex meshes to store polygon meshes to realize  surface rendering 
% isosurface contains the Marching Cubes algorithm to create a polygonal mesh representing the isosurface.

% Create a figure and plot the isosurface
figure;
p = patch('Faces', f, 'Vertices', v);
% The patch function is used for creating polygonal patches in 3D space. 
% defining a set of polygons by their vertices (V) and the faces (F) that connect these vertices.
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1,1,1])
view(3); % Set the view to 3D
camlight; lighting gouraud


%% pointcloud (code same with "code without removing skull")
% Choose a threshold
threshold = 0.15 * max(volume3D(:));

% Find points above the threshold
pointsIdx = find(volume3D > threshold);

% Convert indices to subscripted coordinates
[x, y, z] = ind2sub(size(volume3D), pointsIdx);

% Create the point cloud
ptCloud = pointCloud([x, y, z]);

% Visualize the point cloud
figure;
pcshow(ptCloud);


%% volume rendering (code same with "code without removing skull")
% normalize the intensity values of the image data to a standard range [0,1]
volume3D = rescale(volume3D);

% Create a colormap with three color channels
colormap = [linspace(0, 1, 256)', zeros(256, 2)]; % Red gradient; render higher intensity values in red; other two channels are set zero
% The alpha map, which controls transparency, has been set to make lower intensity values more transparent

% Define an alpha map for transparency; square: making lower intensities more transparent
alphaMap = linspace(0, 1, 256).^2; % Quadratic scale for alpha values

% Perform volume rendering with former settings
h = volshow(volume3D, 'Colormap', colormap, 'Alphamap', alphaMap);% volshow renders the 3D volume using the specified colormap and alpha map.

% Adjust the view settings and axis
view(3); % Standard 3D view
%axis tight; % Fit the axes tightly to the volume
%%daspect([1 1 1]); % Equal aspect ratio for all axes

