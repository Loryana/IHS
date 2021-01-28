path = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\IHS';

dossier = dir(path);

for i=1:22
   if length(dossier(i,1).name)>3
       assignin('base',strcat('file',num2str(i)),dir(strcat(path,'\',dossier(i,1).name)));
   end
end

for i=3:22
    test=eval(strcat('file',num2str(i)));
    for j=1:length(test(:,1))
        [A1,A2,A3]=fileparts(strcat(path,'\',dossier(i,1).name,'\',test(j,1).name));
        switch lower(A3)
            case '.hyspex'
               [hs, info] = hsread(strcat(path,'\',dossier(i,1).name,'\',test(j,1).name));
               hs = double(hs)/65536; % image codée en uint16 : divisé pour avoirdes valeurs comprises entre 0 et 1
               wl = info.wavelength; % Les longueurs d'ondes
               figure, imshow(hs(:,:,50)*10); %%% Afficher l'image en fausse couleur
               res=(size(hs));
               if res(1)==320
                   ncol = 30;% Mettre la colonne limite pour définir le spectralon (ici C'est à peu près à 120)
               elseif res(1)==1600
                   ncol=60;%
               end
               
               etalon = hs(:,1:ncol,:); 
               figure, imshow(etalon(:,:,50)*10); % Afficher juste le spectralon pour vérifier qu'il n'y a pas de soucis:
               
               imagepath=strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Spectralon IHS\',dossier(i,1).name,'_',A2,'.jpg');
               imwrite(etalon(:,:,50)*10,imagepath,'jpg','Quality',100);
               close all;
               [lines cols lambda] = size(etalon);
               i0 = etalon; % division par les valeurs de réflectances (/100 pour passer en pourcentage)
               i0_m = mean(i0,2); % calcul de la valeur moyenne de i0 pour les colonnes
               i0_m_mat = repmat(i0_m, [1 size(hs,2) 1]); % mise à la taille de I_p
               hs_R = hs./i0_m_mat; % correction en reflectance
               clear hs i0_m_mat
               imshow(hs2rgb(hs_R))
               hs_R_list = reshape(hs_R,size(hs_R,1)*size(hs_R,2),size(hs_R,3));
               [~,column_NA] = find(isnan(hs_R_list));
               longueurs_dondes_to_remove= unique(column_NA);
               hs_R(:,:,longueurs_dondes_to_remove)= [];
               wl(longueurs_dondes_to_remove) = [];
               clear hs_R_list
               I=hs2rgb(hs_R);
               imshow(I)
%                BW = imbinarize(I,0.15);
%                imshowpair(I,BW,'montage')
%                BW2=BW;
%                for p=1:2
%                    s = regionprops(BW2,'Centroid','Area','PixelIdxList');
%                    [maxValue,index] = max([s.Area]);
%                    if length(index)>0
%                        BW2(s(index).PixelIdxList)=0;
%                    else
%                        disp('Pas d index')
%                    end
%                end
%                s = regionprops(BW2,'Centroid','Area','PixelIdxList');
%                if res(1)==320
%                    num=find([s.Area]<300);
%                elseif res(1)==1600
%                    num=find([s.Area]<5000);
%                end
               data=cube2saisir(hs_R);
               res=size(hs_R);

               if res(1)==320
                   R1340=mean(data.d(:,find(1790<wl & wl<1810)),2);
                   R1710=mean(data.d(:,find(1910<wl & wl<1930)),2);
                   lma=(R1340-R1710)./(R1340+R1710);
                   res_ndvi=reshape(lma,res(1),res(2),1);
               elseif res(1)==1600
                   R900=mean(data.d(:,find(890<wl & wl<910)),2);
                   R680=mean(data.d(:,find(670<wl & wl<690)),2);
                   ndvi=(R900-R680)./(R900+R680);
                   res_ndvi=reshape(ndvi,res(1),res(2),1);
               end
               
               for a=1:res(1)
                   for b=1:res(2)
                       if res(1)==320
                           if res_ndvi(a,b)<0.15
                               res_ndvi(a,b)=0;
                           else
                               res_ndvi(a,b)=1;
                           end
                       elseif res(1)==1600
                           if res_ndvi(a,b)<0.3
                               res_ndvi(a,b)=0;
                           else
                               res_ndvi(a,b)=1;
                           end
                       end
                   end
               end
               BW = imbinarize(res_ndvi,0.5);
               BW2=BW;

               s = regionprops(BW2,'Centroid','Area','PixelIdxList');
               if res(1)==1600
                   num=find([s.Area]<13000);
               elseif res(1)==320
                       num=find([s.Area]<500);
               end
               for o=1:length(num)
                   BW2(s(num(o)).PixelIdxList)=0;
               end
               
%                s = regionprops(BW2,'Centroid','Area','PixelIdxList');
%                for a=1:length(num)
%                    BW2(s(num(a)).PixelIdxList)=0;
%                end
%                s = regionprops(BW2,'Centroid','Area','PixelIdxList');
%                imshowpair(I,BW2(:,:,1),'montage')

               if res(1)==320
                   J = imcrop(BW2,[0 23 size(BW2,2) 252]);
               elseif res(1)==1600
                   J = imcrop(BW2,[0 76 size(BW2,2) 1184]);
               end
               
               s = regionprops(BW2,'Centroid','Area','PixelIdxList');
               
               imagepath1=strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Mask IHS\',dossier(i,1).name,'_',A2,'_imagergb','.jpg');
               imagepath2=strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Mask IHS\',dossier(i,1).name,'_',A2,'_masque','.jpg');
               imwrite(I,imagepath1,'jpg','Quality',100);
               imwrite(J(:,:,1),imagepath2,'jpg','Quality',100);
               close all;
               
               for w=1:length([s.Area])
                   BW_m=zeros(size(BW2));
                   comp=s(find([s.Area]==s(w,1).Area)).PixelIdxList;
                   for z=1:length(comp)
                       BW_m(comp(z))=1;
                   end
                   matr=zeros(nnz(BW_m(:,:,1)==1),size(hs_R,3));
                   num=0;
                   for a=1:size(hs_R,1)
                       for b=1:size(hs_R,2)
                           if res(1)==320
                               if BW_m(a,b,1)>0 & 23<=a<=252
                                   num=num+1;
                                   for k=1:size(hs_R,3)
                                       matr(num,k)=hs_R(a,b,k);
                                   end
                               end
                           elseif res(1)==1600
                               if BW_m(a,b,1)>0 & 76<=a<=1184
                                   num=num+1;
                                   for k=1:size(hs_R,3)
                                       matr(num,k)=hs_R(a,b,k);
                                   end
                               end
                           end
                       end
                   end
                   save(strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Output IHS\',dossier(i,1).name,'_',A2,'_',string(w),'.mat'),'matr')
                   close all;
%                    plot(wl,matr);
%                    xlabel('Wavelength(nm)');
%                    ylabel('Reflectance');
%                    imagepath3=strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Plot IHS\',dossier(i,1).name,'_',A2,'_feuille',string(w),'.fig');
%                    savefig(imagepath3);
               end
               disp('f')
            otherwise
               disp('nop')
        end
%         if A3 == '.hyspex'
%             [hs, info] = hsread(test(j,1).name);
%             print("Ca fonctionne")
%         end
    end

end


%% 

filepath = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\IHS\20201125\61_50000_us_4x_HSNR02_2020-11-25T102545_corr.hyspex';

%%%01_50000_us_4x_HSNR02_2020-11-19T091415_corr.hyspex
%%%01_12000_us_HSNR05_2020-11-19T091759_corr.hyspex

%%49_12000_us_HSNR25_2020-12-11T085937_corr.hyspex

%%% SWIR : ncol=30  VNIR ncol=120

[hs, info] = hsread(filepath); %Il faut la fonction hsread
hs = double(hs)/65536; % image codée en uint16 : divisé pour avoirdes valeurs comprises entre 0 et 1
wl = info.wavelength; % Les longueurs d'ondes
%% 

figure, imshow(hs(:,:,50)*10); %%% Afficher l'image en fausse couleur
ncol = 30;% Mettre la colonne limite pour définir le spectralon (ici C'est à peu près à 120)
etalon = hs(:,1:ncol,:); 
figure, imshow(etalon(:,:,50)*10); % Afficher juste le spectralon pour vérifier qu'il n'y a pas de soucis:

imwrite(etalon(:,:,50)*10,'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Spectralon IHS\image_tres_jolie.jpg','jpg','Quality',100);

%% 

close all;
%% 

%%% Divisions des pixels de l'image hs par les spectres moyens par lignes
[lines cols lambda] = size(etalon);
i0 = etalon; % division par les valeurs de réflectances (/100 pour passer en pourcentage)
i0_m = mean(i0,2); % calcul de la valeur moyenne de i0 pour les colonnes
i0_m_mat = repmat(i0_m, [1 size(hs,2) 1]); % mise à la taille de I_p
hs_R = hs./i0_m_mat; % correction en reflectance
clear hs i0_m_mat

%% 


%%% Mon image est hs_R !! 
imshow(hs2rgb(hs_R))
hs_R_list = reshape(hs_R,size(hs_R,1)*size(hs_R,2),size(hs_R,3));
[~,column_NA] = find(isnan(hs_R_list))
longueurs_dondes_to_remove= unique(column_NA)
hs_R(:,:,longueurs_dondes_to_remove)= [];
wl(longueurs_dondes_to_remove) = [];
clear hs_R_list
%% 

% %%% Piocher les spectres dans l'image : 
[sp,mask,nbpix]=hsextractsparsespectragui(hs_R);
plot(wl,sp)
xlabel('Wavelength(nm)')
ylabel('Reflectance')


%%
figure;
plot(wl,mean(sp1),'r')
hold on
plot(wl,mean(sp),'g')


%%

data=cube2saisir(hs_R);
res=size(hs_R);

if res(1)==320
    R1340=mean(data.d(:,find(1790<wl & wl<1810)),2);
    R1710=mean(data.d(:,find(1910<wl & wl<1930)),2);
    lma=(R1340-R1710)./(R1340+R1710);
    res_ndvi=reshape(lma,res(1),res(2),1);
elseif res(1)==1600
    R900=mean(data.d(:,find(890<wl & wl<910)),2);
    R680=mean(data.d(:,find(670<wl & wl<690)),2);
    ndvi=(R900-R680)./(R900+R680);
    res_ndvi=reshape(ndvi,res(1),res(2),1);
end

imshow(res_ndvi)

%%
for a=1:res(1)
    for b=1:res(2)
        if res_ndvi(a,b)<0.15
            res_ndvi(a,b)=0;
        else
            res_ndvi(a,b)=1;
        end
    end
end

imshow(res_ndvi)

%%

BW = imbinarize(res_ndvi,0.5);
imshowpair(res_ndvi,BW,'montage')
BW2=BW;



s = regionprops(BW2,'Centroid','Area','PixelIdxList');
num=find([s.Area]<500);
for i=1:length(num)
    BW2(s(num(i)).PixelIdxList)=0;
end
s = regionprops(BW2,'Centroid','Area','PixelIdxList');



imshowpair(res_ndvi,BW2,'montage')
% [coeff,score,latent,tsquared,explained,mu] = pca(data.d);
% 
% biplot(coeff(:,1:2),'scores',score(:,1:2));

%%
I=hs2rgb(hs_R);
imshow(I)
level = 0.4039;
BW = imbinarize(I,0.15);
imshowpair(I,BW,'montage')
BW2=BW;

for i=1:2
    s = regionprops(BW2,'Centroid','Area','PixelIdxList');

    [maxValue,index] = max([s.Area]);

    BW2(s(index).PixelIdxList)=0;
end

s = regionprops(BW2,'Centroid','Area','PixelIdxList');
num=find([s.Area]<800);
for i=1:length(num)
    BW2(s(num(i)).PixelIdxList)=0;
end
s = regionprops(BW2,'Centroid','Area','PixelIdxList');



imshowpair(I,BW2(:,:,1),'montage')
% imwrite(I,'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Spectralon IHS\2.jpg','jpg','Quality',100);
% imwrite(BW2(:,:,1),'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Spectralon IHS\image_tres_jolie.jpg','jpg','Quality',100);

%%
J = imcrop(I,[0 23 317 252]);
imshowpair(I,J,'montage')


%%%J=inpaintCoherent(I,BW2(:,:,3));
%%%imshow(J)
%% 

close all;
%%

for w=1:length([s.Area])
    BW=zeros(size(BW2));
    BW(s(find([s.Area]==s(w,1).Area)).PixelIdxList)=1;
    matr=zeros(nnz(BW(:,:,1)==1),size(hs_R,3));
    num=0;
    for i=1:size(hs_R,1)
       for j=1:size(hs_R,2)
           if BW(i,j,1)>0
               num=num+1;
               for k=1:size(hs_R,3)
                   matr(num,k)=hs_R(i,j,k);
               end
           end  
       end
    end
%     save(strcat('output',string(w),'.mat'),'matr')
      plot(wl,matr);
%      xlabel('Wavelength(nm)');
%      ylabel('Reflectance');
%     imagepath3=strcat('C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Plot IHS\',dossier(i,1).name,'_',A2,'_feuille',string(w),'.jpg')
%     imwrite(I,imagepath3,'jpg','Quality',100);
end

%%
BW=zeros(size(BW2));
BW(s(find([s.Area]==s(w,1).Area)).PixelIdxList)=1;
matr=zeros(nnz(BW2(:,:,1)==1),size(hs_R,3));
num=0;
for i=1:size(hs_R,1)
   for j=1:size(hs_R,2)
       if BW2(i,j,1)>0
           num=num+1;
           for k=1:size(hs_R,3)
               matr(num,k)=hs_R(i,j,k);
           end
       end  
   end
end

%%
[coeff,score,latent,tsquared,explained,mu] = pca(matr);

biplot(coeff(:,1:2),'scores',score(:,1:2));

%%
path = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip 2020\Output IHS';

res_swir=[];
res_vnir=[];

dossier = dir(path);
for i=3:length(dossier(:,1))
    load(strcat(path,'\',dossier(i,1).name));
    if size(matr,2)==80
        res_vnir=[res_vnir;mean(matr)]
    elseif size(matr,2)==256
        res_swir=[res_swir;mean(matr)]
    end
    
end

%%
save('res_swir.mat','res_swir')
save('res_vnir.mat','res_vnir')

%%
% plot(wl,res_vnir)
plot(wl,res_swir)

%%


[coeff,score,latent,tsquared,explained,mu] = pca(res_vnir);

biplot(coeff(:,1:2),'scores',score(:,1:2));

% res=min(matr);
% plot(wl,res);
% xlabel('Wavelength(nm)');
% ylabel('Reflectance');

% mat=zeros(nnz(BW2(:,:,1)==1),size(hs_R,3));
% num=0;
% for i=1:size(hs_R,1)
%     for j=1:size(hs_R,2)
%         if BW2(i,j,1)>0
%             num=num+1;
%             for k=1:size(hs_R,3)
%                 mat(num,k)=hs_R(i,j,k);
%             end
%         end  
%     end
% end

% plot(wl,mat)
% xlabel('Wavelength(nm)')
% ylabel('Reflectance')
        