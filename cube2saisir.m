function x=cube2saisir(cube_image,mask,code)
%cube2saisir             - Transform a cube_image into a saisir structure
%function x=cube2saisir(cube_image,[mask],(code))
% Unfold the cube_image into a matrix, giving the identifier 'code'
% to every pixel.
% returns a saisir matrix having n*p rows and q columns,
% where n, p q are the number of image-row, image-column and channels.
% x.row contains the initial row position of the pixel in the cube image
% x.column contains the initial column position

if(nargin<3)
    code='.';
end;
[n,p,q]=size(cube_image);
x.d=reshape(cube_image,(n*p),q);
x.v=num2str1((1:q)',2);
bid=[1:n];
bid1=ones(p,1)*bid;
bid2=reshape(bid1',1,n*p)';
%index1=num2str(reshape(bid1',1,n*p)')
x.row=bid2;
bid=[1:p];
bid1=ones(n,1)*bid;
bid2=reshape(bid1,1,n*p)';
x.column=bid2;
x.i=char(ones(n*p,1)*code);
x.d=double(x.d);

if((nargin>1)&(~isempty(mask)))
    mask=reshape(mask,(n*p),1);
    x=selectrow(x,mask==1);
end
