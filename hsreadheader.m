function info=hsreadheader( fname )
%HSREADHEADER Reads hyperspectral's header file .hdr.
%   info=hsreadheader( fname ) Reads the header file specified by fname 
%   return informations into a structure :
%       info.samples        : number of samples 
%       info.lines          : number of lines 
%       info.bands          : number of bands
%       info.offset         : offset of binary file
%       info.datatype       : type of data (bit8, ..., uint64)
%       info.datasize       : size in bytes of data
%       info.interleave     : type of interleave
%       info.wavelength     : wavelengths of the bands
%
%   
%
info=[];

% Parameters initialization
elements={'samples' 'lines' 'bands' 'datatype' 'headeroffset' 'interleave'};
d={ 'uint8' 'int16' 'int32' 'single' 'double' 'uint16' 'uint32' 'int64' 'uint64'};
ds=[   1       2       4       4        8        2         4       8         8  ];

% Check user input
if ~ischar(fname)
    error('fname should be a char string');
end


% Open ENVI header file to retreive s, l, b & d variables
rfid = fopen(fname,'r');

if rfid==-1
    error(sprintf('error while opening %s', fname));
    return;
end;

% Read ENVI image header file and get p(1) : nb samples,
% p(2) : nb lines, p(3) : nb bands and t : data type

while 1
    tline = fgetl(rfid);
    
    if ~ischar(tline), break, end
    
    [first,second]=strtok(tline,'=');
    first(first==' ')=[];
    
    switch first
        case 'wavelength'
            
            while isempty(find(second=='}'))
                second = [second fgetl(rfid)];
            end;
            [f,s]=strtok(second);
            s(find(s=='{'))=' ';
            s(find(s=='}'))=' ';
            info.wavelength = strread( s, '%f', 'delimiter',',' );
        case 'interleave'
            [f,s]=strtok(second);
            s(find(s==' '))=[];
            info.interleave = lower(s);
        case 'headeroffset'
            [f,s]=strtok(second);
            info.offset = str2num(s);
        case 'samples'
            [f,s]=strtok(second);
            info.samples = str2num(s);
        case 'lines'
            [f,s]=strtok(second);
            info.lines = str2num(s);
        case 'bands'
            [f,s]=strtok(second);
            info.bands = str2num(s);
        case 'datatype'
            [f,s]=strtok(second);
            t=str2num(s);
            switch t
                case 1
                    t=d{1};
                    sz=ds(1);
                case 2
                    t=d{2};
                    sz=ds(2);
                case 3
                    t=d{3};
                    sz=ds(3);
                case 4
                    t=d{4};
                    sz=ds(4);
                case 5
                    t=d{5};
                    sz=ds(5);
                case 12
                    t=d{6};
                    sz=ds(6);
                case 13
                    t=d{7};
                    sz=ds(7);
                case 14
                    t=d{8};
                    sz=ds(8);
                case 15
                    t=d{9};
                    sz=ds(9);
                otherwise
                    error('Unknown image data type');
            end
            info.datatype=t;
            info.datasize=sz;
    end
end
fclose(rfid);