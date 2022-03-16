#MWPCA -----
rm(list=ls())
setwd("~/Thèse/Script/MWPCA fonction")

source("Movingwindowpca_modif_HI2021_distrib.R")
source("asd_read.R")

library(rnirs)
library(ggplot2)
library(R.matlab)

file_spectra="~/Thèse/Manip HI2021/Feuilles_test/Spectres 100"

test_file <- function(path_file){
  if(file.exists(path_file)==T){
    return('Bon fichier')
  }else{
    dir.create(path_file)
  }
}

test_file(file_spectra)

ind='19_G'
num_feuil=2
num_spectra=10000
repetition=3
wchoix=c(1)
date=c('20210311','20210312','20210316','20210317','20210318','20210319',
       '20210320','20210322','20210323','20210324','20210325','20210326',
       '20210327','20210328','20210329','20210330','20210331','20210401')

path_cwd <- "C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Output VNIR"
path_cwd
setwd(path_cwd)
filename_tot=dir(path = path_cwd)

filename=c()
for(tot in 1:length(filename_tot)){
  if(substr(filename_tot[tot],10,13)==ind & substr(filename_tot[tot],56,56)==num_feuil){
    filename=c(filename,filename_tot[tot])
  }
}


T1<-Sys.time()
result=vector("list",repetition)
for(uti in 1:repetition){
  for(w in 1:length(wchoix)){
    
    chemin='C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Spectres 100'
    
    for(i in 1:length(filename)){
      
      setwd(path_cwd)
      data=readMat(filename[i])
      samp=sample(c(1:nrow(data$matr)),num_spectra)
      data_rand=data$matr[samp,]
      
      test_file(chemin)
      setwd(chemin)
      paste(substr(filename[i],10,13),substr(filename[i],55,56),'_',
            substr(filename[i],1,8),'.jpg',sep='')
      name_file=paste(substr(filename[i],1,8),
                      '_',
                      substr(filename[i],10,13),
                      substr(filename[i],55,56),
                      '_',
                      num_spectra,'.RData',sep='')
      save(data_rand,file=name_file)
    }
    
    datagen=data.frame(matrix(NA, nrow=num_spectra*length(date), ncol=216)) #216 pour les VNIR uniquement
    date_gen=c()
    
    setwd(file_spectra)
    for(i in 1:length(date)){
      filename2=paste(date[i],'_',ind,'_',num_feuil,'_',num_spectra,'.RData',sep='')
      load(filename2)
      datagen[c((1+(num_spectra*(i-1))):(num_spectra*i)),]=data_rand
      date_gen=c(date_gen,rep(i,num_spectra))
    }
    
    if((2*nrow(data_rand))>ncol(data_rand)){
      ncomposante=ncol(data_rand)-1
    }else{
      ncomposante=(2*nrow(data_rand))-1
    }
    
    oh=window_pca(H=wchoix,
                  datagen_table=data.frame(datagen),
                  datagen_test=data.frame(datagen),
                  nco=ncomposante,date_gen=date_gen,
                  date_gen_test=date_gen,
                  datemax=max(date_gen),
                  rnirmeth=TRUE)
  }
  result[[uti]] = oh
  
  # chemfinal=paste('C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Résultat VNIR',
  #                 '/',ind,sep='')
  # test_file(chemfinal)
  # setwd(chemfinal)
  # nomplot=paste(ind,'_',num_feuil,'_',uti,'_','T².jpg',sep='')
  # jpeg(nomplot, width = 900, height = 500)
  # plot(strptime(date[-c(1,2)],"%Y%m%d"),rowMeans(result[[uti]]),type='l',
  #      main=paste(ind,'feuille',num_feuil,'T²'),
  #      xlab="Temps",ylab="T²")
  # dev.off()
  # nomplot2=paste(ind,'_',num_feuil,'_',uti,'_','SD.jpg',sep='')
  # jpeg(nomplot2, width = 900, height = 500)
  # plot(strptime(date[-c(1,2)],"%Y%m%d"),c(apply(result[[uti]],1,sd)),type='l',
  #      main=paste(ind,'feuille',num_feuil,'Ecart-type'),
  #      xlab='Temps',ylab='Ecart-type')
  # dev.off()
  
  
  T2<-Sys.time() 
}

setwd("~/Thèse/Manip HI2021/Feuilles_test/Résultat_distrib")
#save(result,file=paste(num_spectra,'_distrib_nco_',ncomposante,'.RData',sep=''))

Tdiff= difftime(T2, T1) 
