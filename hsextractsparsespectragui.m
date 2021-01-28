function [sp,mask,nbpix]=hsextractsparsespectragui(hsi,mask)
% Extract spectra from different regions of the HS image loaded in memory.

if nargin<2
    ok=0;

    %% GUI creation

    hFigure     =   figure(...
        'Units','Normalized',...
        'Position',[0.1 0.1 0.8 0.8]);

    hPanelIm  =    uipanel(...
        'Parent',hFigure,...
        'Units','Normalized',...
        'Clipping','on',...
        'Position',[.005 .005 0.90 0.945]);

    hAxesIm   =   axes(...
        'Parent',hPanelIm,...
        'vis','on',...
        'Units','Normalized',...
        'Position',[.05 .05 .9 .9]);

    hOKButton       =   uicontrol(...
        'Parent',hFigure,...
        'Units','Normalized',...
        'Position',[.91 .05 .08 .03],...
        'String','OK',...
        'Callback',@hOKButtonCallback);

    RGB=[62, 48, 12];% Camera IQ?
%     imshow(hs2rgb(REFLECTANCE, RGB)*4);
    hsiRGB = hs2rgb(hsi);
    
    mask=zeros(size(hsiRGB,1),size(hsiRGB,2));
    hsiRGB_sorted = sort(hsiRGB(:));
    nbpix=[]; 
    while ok==0
        mask = mask+roipoly(1*hsiRGB./  hsiRGB_sorted( round( length(hsiRGB_sorted)*99/100) ) );
        nbpix=[nbpix length(find(mask>0))]; 
    end
else
    mask=reshape(mask,size(mask,1)*size(mask,2),size(mask,3));
end
I=reshape(hsi,size(hsi,1)*size(hsi,2),size(hsi,3));
for i=1:size(hsi,3)
    sp(:,i)=I(find(mask),i);
end

mask=reshape(mask,size(mask,1),size(mask,2),size(mask,3));

% -------------------------------------------------------------------
function hOKButtonCallback(hObject, eventdata)
        % Callback called when the OK button is pressed
        ok=1;
end
% ----------------------------------------------------------------------

end