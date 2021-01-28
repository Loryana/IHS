function im=hs2rgb(hs,RGB)
%HS2RGB Returns 3 plan rgb image specified with RGB values
%
% 
if nargin==1
    RGB=[27, 20, 6];% Camera Hyspex
end

im=zeros(size(hs(:,:,1)));
im(:,:,1)=hs(:,:,RGB(1));
im(:,:,2)=hs(:,:,RGB(2));
im(:,:,3)=hs(:,:,RGB(3));