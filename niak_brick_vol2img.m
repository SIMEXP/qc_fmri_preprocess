function [in,out,opt] = niak_brick_vol2img(in,out,opt)
% Generate a figure with a montage of different slices of a volume 
%
% SYNTAX: [IN,OUT,OPT] = NIAK_BRICK_VOL2IMG(IN,OUT,OPT)
%
% IN.SOURCE (string) the file name of a 3D volume
% IN.TARGET (string, default '') the file name of a 3D volume defining the target space. 
%   If left empty, or unspecified, IN.VOL is used as the target. 
% OUT (string) the file name for the figure. The extension will determine the type. 
% OPT.COORD (array N x 3) 
% OPT.COLORBAR (boolean, default true)
% OPT.COLORMAP (string, default 'gray') The type of colormap. Anything supported by 
%   the instruction `colormap` will work. 
% OPT.TITLE (string, default '') a title for the figure. 
% OPT.LIMITS (vector 1x2) the limits for the colormap. By defaut it is using [min,max].


%% Defaults
in = psom_struct_defaults( in , ...
    { 'source' , 'target' }, ...
    { NaN       , ''          });
    
if isempty(in.target)
    in.target = in.source;
end

opt = psom_struct_defaults ( opt , ...
    { 'colorbar' , 'coord' , 'limits' , 'colormap' , 'title' }, ...
    { true         , NaN     , []        , 'gray'         , ''       });

%% Read the data 
hdr.target = niak_read_vol(in.target);
[hdr.source,vol] = niak_read_vol(in.source);

%% Generate the image
for cc = 1:size(opt.coord,1)
    [img_tmp,slices] = niak_vol2img(hdr,vol,opt.coord(cc,:));
    if cc == 1
        img = img_tmp;
        size_slices = size(slices{1});
        size_slices = [size_slices ; size(slices{2})];
        size_slices = [size_slices ; size(slices{3})];
    else
        img = [img ; img_tmp];
    end
end

%% The image
hf = figure;
if isempty(opt.limits)
    climits = [min(img(:)) max(img(:))];
else
    climits = opt.limits;
end
imagesc(img,climits);

%% Colorbar/map
colormap(opt.colormap);
daspect([1 1]);
if opt.colorbar
    colorbar
end

%% Title
if ~isempty(opt.title)
    title(opt.title)
end

%% Set X axis 
ha = gca;
valx = zeros(3,1);
valx(1) = size_slices(1,2)/2;
valx(2) = size_slices(2,2)/2 + size_slices(1,2);
valx(3) = size_slices(3,2)/2 + size_slices(2,2) + size_slices(1,2);
set(ha,'xtick',valx);
set(ha,'xticklabel',{'sagital','coronal','axial'})

%% Set y axis
ny = size(img,1);
valy = round(linspace(1,ny,size(opt.coord,1)*2+1));
label_view = cell(1,size(opt.coord,1));
for cc = 1:size(opt.coord,1)
    label_view{cc} = sprintf('(%i,%i,%i)',round(opt.coord(cc,1)),round(opt.coord(cc,2)),round(opt.coord(cc,3)));
end
set(ha,'ytick',valy(2*(1:size(opt.coord,1))));
set(ha,'yticklabelmode','manual')
set(ha,'yticklabel',label_view);

%% Deal with font type and size
%FN = findall(ha,'-property','FontName');
%set(FN,'FontName','/usr/share/fonts/truetype/dejavu/DejaVuSerifCondensed.ttf');
FS = findall(ha,'-property','FontSize');
set(FS,'FontSize',8);

%% Save figure
print(out,'-dpng');
close(hf)