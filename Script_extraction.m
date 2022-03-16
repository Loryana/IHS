%path = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip HI2021\SWIR';
path_gen = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip HI2021\Feuilles_test';
path = 'C:\Users\heloise.villesseche\Documents\Thèse\Manip HI2021\Feuilles_test\VNIR_test';

dossier = dir(path);

for i=1:20
   if length(dossier(i,1).name)>3
       assignin('base',strcat('file',num2str(i)),dir(strcat(path,'\',dossier(i,1).name)));
   end
end

for i=3:20
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
               if res(1)==320 %SWIR
                   ncol = 25;% Mettre la colonne limite pour définir le spectralon (ici C'est à peu près à 120)
               elseif res(1)==1024
                   ncol=50;
               elseif res(1)==2048
                   ncol=80;
               end
               
               etalon = hs(:,1:ncol,:); 
               figure, imshow(etalon(:,:,50)*10); % Afficher juste le spectralon pour vérifier qu'il n'y a pas de soucis:
               
               if res(1)==320
                   imagepath=strcat(path_gen,'\Spectralon SWIR\',dossier(i,1).name,'_',A2,'.jpg');
               elseif res(1)==1024
                   imagepath=strcat(path_gen,'\Spectralon VNIR\',dossier(i,1).name,'_',A2,'.jpg');
               elseif res(1)==2048
                   imagepath=strcat(path_gen,'\Spectralon VNIR\',dossier(i,1).name,'_',A2,'.jpg');
               end 
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
               
               if res(1)==320
                   level = 0.15;
               elseif res(1)==1024
                   level = 0.22;
               elseif res(1)==2048
                   level = 0.2;
               end
               
               BG = imgaussfilt(I,0.6);
               BW = imbinarize(BG,level);
               imshowpair(I,BW,'montage')
               if res(1)==320
                   se = strel('square',2);
                   BW = imclose(BW,se);
               elseif res(1)==1024
                   se = strel('square',10);
                   BW = imclose(BW,se);
               elseif res(1)==2048
                   se = strel('square',20);
                   BW = imclose(BW,se);
               end

               
               BW2=BW;
               for l=1:2
                   s = regionprops(BW2,'Centroid','Area','PixelIdxList');

                   [maxValue,index] = max([s.Area]);

                   BW2(s(index).PixelIdxList)=0;
                   BW(s(index).PixelIdxList)=0;
               end

               s = regionprops(BW2,'Centroid','Area','PixelIdxList');
               num=find([s.Area]<2500);
               for l=1:length(num)
                   BW2(s(num(l)).PixelIdxList)=0;
                   BW(s(num(l)).PixelIdxList)=0;
               end
               
               if res(1)==1024
                   rect=[0 110 1370 780];
               elseif res(1)==2048
                   rect=[0 150 2740 1560];
               end
               
               

               if res(1)==320               
                   s = regionprops(BW2,'Centroid','Area','PixelIdxList');
                   imagepath1=strcat(path_gen,'\Mask SWIR\',dossier(i,1).name,'_',A2,'_imagergb','.jpg');
                   imagepath2=strcat(path_gen,'\Mask SWIR\',dossier(i,1).name,'_',A2,'_masque','.jpg');
                   imwrite(I,imagepath1,'jpg','Quality',100);
                   imwrite(BW2,imagepath2,'jpg','Quality',100);
               elseif res(1)==1024
                   BI = imcrop(BW2,rect);               
                   s = regionprops(BI,'Centroid','Area','PixelIdxList');
                   imagepath1=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_imagergb','.jpg');
                   imagepath2=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_masque','.jpg');
                   imwrite(I,imagepath1,'jpg','Quality',100);
                   imwrite(BI,imagepath2,'jpg','Quality',100);
               elseif res(1)==2048
                   BI = imcrop(BW2,rect);               
                   s = regionprops(BI,'Centroid','Area','PixelIdxList');
                   imagepath1=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_imagergb','.jpg');
                   imagepath2=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_masque','.jpg');
                   imwrite(I,imagepath1,'jpg','Quality',100);
                   imwrite(BI,imagepath2,'jpg','Quality',100);
               end 
               
               BI2=zeros(size(BI(:,:,1)));
               BI2(find(BI(:,:,1)==1))=1;
               BI2(find(BI(:,:,2)==1))=1;
               BI2(find(BI(:,:,3)==1))=1;
               BI2=logical(BI2);
               L = bwlabel(BI2);
               
               if res(1)==320
                   imagepath3=strcat(path_gen,'\Mask SWIR\',dossier(i,1).name,'_',A2,'_L','.jpg');
               elseif res(1)==1024
                   imagepath3=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_L','.jpg');
               elseif res(1)==2048
                   imagepath3=strcat(path_gen,'\Mask VNIR\',dossier(i,1).name,'_',A2,'_L','.jpg');
               end
               imshow(L,[0 5])
               labelsRange = getframe;
               imwrite(labelsRange.cdata,imagepath3,'jpg','Quality',100);
               
               close all;
               
               s2 = regionprops(L,'Area');
               s2_size=size(s2);
               
               if s2_size(1)>=3 
                   w_end=3;
               else
                   w_end=2;
               end
               
               BX=L;
               
               for w=1:w_end
                   
                   num=w;
                   layer=find(BX==num);

                   matr=zeros(length(layer),res(3));
                   for z=1:res(3)
                       if res(1)==320
                           coup=hs_R(:,:,z);
                       elseif res(1)==1024
                           coup=imcrop(hs_R(:,:,z),rect);
                       elseif res(1)==2048
                           coup=imcrop(hs_R(:,:,z),rect);
                       end
                       matr(:,z)=coup(layer);
                   end
                  
                  
                  if res(1)==320
                      save(strcat(path_gen,'\Output SWIR\',dossier(i,1).name,'_',A2,'_',string(w),'.mat'),'matr');
                  elseif res(1)==1024
                      save(strcat(path_gen,'\Output VNIR\',dossier(i,1).name,'_',A2,'_',string(w),'.mat'),'matr');
                  elseif res(1)==2048
                      save(strcat(path_gen,'\Output VNIR\',dossier(i,1).name,'_',A2,'_',string(w),'.mat'),'matr');
                  end
%                   set (0, 'defaultfigurevisible', 'off')
%                    plot(wl,matr);
%                    xlabel('Wavelength(nm)');
%                    ylabel('Reflectance'ee);
%                    if res(1)==320
%                        imagepath3=strcat(path_gen,'\Spectralon SWIR\',dossier(i,1).name,'_',A2,'.jpg');
%                    elseif res(1)==1024
%                        imagepath3=strcat(path_gen,'\Plot SWIR\',dossier(i,1).name,'_',A2,'_feuille',string(w),'.fig');
%                    elseif res(1)==2048
%                        imagepath3=strcat(path_gen,'\Plot SWIR\',dossier(i,1).name,'_',A2,'_feuille',string(w),'.fig');
%                    end 
%                   imwrite(I,imagepath3,'jpg','Quality',100);
               end

               disp('f')
            otherwise
               disp('nop')
        end
    end
end