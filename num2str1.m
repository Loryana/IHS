function str=num2str1(number,ndigit);
%num2str1      -  Justified num2string
%function str=num2str1(vector,ndigit);
%
%Input arguments:
%===============
%
%vector : Matlab vector of integers
%ndigit : positive integer
%
%This function  transforms numbers into matrices of char. 
%The function justifies the strings by adding zeros.
%
%If the first argument is a row vector, it is transposed 
%
% % %Example
% % %=======
% x=[1 2 100];
% x1=num2str1(x,5);
% x1
% % 00001
% % 00002
% % 00100
%The main use of this function is to help building smart row names
%in SAISIR matrices using the system of extractable fields in the names.
%
%
[n,p]=size(number);
if((p~=1)&&(n~=1)) %% not a vector
    error('The first argument must be a row or a column vector');
    str=[];
    return;
end
if(n<p)
    number=number';
    disp('The vector has been transposed');
    [n,p]=size(number);
end
aux=char('0'*ones(n,ndigit));
%aux
aux1=num2str(number);
[n,p]=size(aux1);
str=[aux(:,1:ndigit-p) aux1];
str(str==' ')='0';