function [hsData,info] = hsread(hsFile)
%HSREAD Read an hyperspectral Image.
%   [hsData,info] = hsread(hsFile)   
%   hsread loads the hyperspectral image in the main memory if an hsFile
%   is specified or displays a dialogue box to pick up an hyperspectral
%   image and loads it then. 
%   [hsData] = hsRead(hsFile) runs the function. And return the full data
%   cube in hsData.
%   Note : hsData is loaded in the main memory in a BSQ fashion so 
%   size(hsData)= [samples, lines, bands] for all sorts of hyperspectral images
%   wl correspond to the wavelenght vector contained in the header file. 
%   [hsData,wl] = hsRead(hsFile) runs the function with a specified
%   hsFile and returns the hs data cube in hsData and the wavelength vector in wl. 
%   [hsData,wl] = hsRead runs the same function as above but first opens a dialog
%   box to find the appropriate hyperspectral image in the hard drive.
%
%   11/09/2012   
%   xavier.hadoux@gmail.com
%
%   See also hsREADSUBIMAGE,hsWRITE, hsREADHEADER


if nargin==0
    [path, name, ext]=hsgetfile();
elseif nargin==1
    [path, name, ext] = fileparts(hsFile);
    path=[path,'\'];
else
    error('Wrong number of input arguments')
end


% Get the FID of the file
fid = fopen( [path,name,ext],'rb');
% Read the header
info=hsreadheader([path,name,'.hdr']);

samples  =info.samples;
lines    =info.lines;
bands    =info.bands;
offset   =info.offset;
datasize =info.datasize;
datatype =info.datatype;
wl       =info.wavelength;

% PreAllocate memory for hsData
hsData=zeros(samples,lines,bands);
% X goes from 1 : samples
% Y goes from 1 : lines
% Z goes from 1 : bands

%% BSQ (Band Sequential Format)
% In its simplest form, the data is in BSQ format, with each line of the
% followed immediately by the next line in the same spectral band. This format
% is optimal for spatial (X, Y) access of any part of a single spectral band.

%% BIP (Band Interleaved by Pixel Format)
% Images stored in BIP format have the first pixel for all bands in sequential
% order, followed by the second pixel for all bands, followed by the third pixel
% for all bands, etc., interleaved up to the number of pixels. This format
% provides optimum performance for spectral (Z) access of the image data.

%% BIL (Band Interleaved by Line Format)
% Images stored in BIL format have the first line of the first band followed
% by the first line of the second band, followed by the first line of the third
% band, interleaved up to the number of bands. Subsequent lines for each band
% are interleaved in similar fashion. This format provides a compromise in
% performance between spatial and spectral processing and is the recommended
% file format for most ENVI processing tasks.


switch info.interleave
    case 'bil'
        hwb = waitbar(0,'Reading (X - Lambda) planes from BIL hs Data...');
        jump =  offset ;
        fseek(fid, jump, 'bof');
        
        for Y=1:lines
            waitbar(Y/lines);
            hsData(:,Y,:)= reshape(fread(fid, samples*bands, datatype),samples,bands);
            %size(tmp) 160 1600
            %size(hsData)
        end
        close(hwb);
        
    case 'bsq'
        hwb = waitbar(0,'Reading (X - Y) planes from BSQ hs Data...');
        jump =  offset ;
        fseek(fid, jump, 'bof');
        
        for Z=1:bands
            waitbar(Z/bands);
            Z
            hsData(:,:,Z) = reshape(fread(fid, samples*lines, datatype),samples,lines);
        end
        close(hwb);
    case 'bip'
        hwb = waitbar(0,'Reading (Y) lines from BIP hs Data...');
        jump =  offset ;
        fseek(fid, jump, 'bof');
        
        for Y=1:lines
            waitbar(Y/lines);
            hsData(:,Y,:)= reshape(fread(fid, samples*bands, datatype),bands,samples)';
        end
        close(hwb);
        
end
% X goes from 1 : samples
% Y goes from 1 : lines
% Z goes from 1 : bands
fclose(fid);

