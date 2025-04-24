function New_dicom = My_removeskull(DCM, direction, threshold)
%{
Using mask to get the area of without skull
Input: DCM: the 3D dataset to be processed, grayscale
       direction: process image trough which surface, 'xz', 'yz'
       threshold: threshold for segmentation, 0-1
Output: 3D dataset without skull, grayscale
Attention: the code is now only for xz and yz surface, if you want to add
           xy surface, just rewrite the line 52-54
%}

[x, y, z] = size(DCM); % measure the size of the data array

% set the different value in different direnction
switch direction
    case 'xz'
        position = 1;
        array = [x, 1, z];
        N = y;
    case 'yz'
        position = 2;
        array = [1, y, z];
        N = x;
end

% use circulation to process each slide, N is the number of slides
for n = 1:N
    switch position
        case 1
            Original_data = DCM(:,n,:);
        case 2
            Original_data = DCM(n,:,:);
    end
    Original_image = squeeze(Original_data); % convert 3D array to 2D
    Binary_image = Original_image > threshold; % threshold segmentation
    % get maximum connected domain
    imLabel = bwlabel(Binary_image);
    stats = regionprops(imLabel,'Area');
    [b,index]=sort([stats.Area],'descend');
    % 1 means only get the first maximum
    if length(stats)<1
        Mask = imLabel;
    else
        Mask = ismember(imLabel,index(1:1)); % get original mask
    end
    % remove the details of the mask to get the complete image
    Mask = imcomplement(Mask); % get reverse image
    Mask = bwareaopen(Mask, 100); % remove patterns smaller than 100 pixels
    Mask = imcomplement(Mask); % get reverse image
    % remove obvious useless information on the top of the image
    if Mask((x+y)/4,z-1)==1
        Mask = zeros;
    end
    % multiple the original image and mask to get interested area
    New_image= bsxfun(@times, Original_image, cast(Mask,class(Original_image)));
    New_surface = reshape(New_image, array);
    % assign value to New_dicom
    switch position
        case 1
            New_dicom(:,n,:) = New_surface;
        case 2
            New_dicom(n,:,:) = New_surface;
    end
end

            