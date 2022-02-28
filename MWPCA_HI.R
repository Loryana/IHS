#MWPCA -----
rm(list=ls())
setwd("~/Thèse/Script/MWPCA fonction")

source("Movingwindowpca_modif_HI2021.R")
source("asd_read.R")

library(rnirs)
library(ggplot2)

file_spectra="~/Thèse/Manip HI2021/Feuilles_test/Spectres 100"
# g_mwpca="~/Thèse/Manip HI2021/Feuilles_test/Spectres R VNIR/MWPCA"
# g_resultat="~/Thèse/Manip HI2021/Feuilles_test/Spectres R VNIR/Résultat"

test_file <- function(path_file){
  if(file.exists(path_file)==T){
    return('Bon fichier')
  }else{
    dir.create(path_file)
  }
}

test_file(file_spectra)

genotyp='19_G'
num_feuil=1
num_spectra=10000
repetition=10
wchoix=c(1)
date=c('20210311','20210312','20210316','20210317','20210318','20210319',
       '20210320','20210322','20210323','20210324','20210325','20210326',
       '20210327','20210328','20210329','20210330','20210331','20210401')

T1<-Sys.time()
result=vector("list",repetition)
for(uti in 1:repetition){
  for(w in 1:length(wchoix)){
     
    
    path_cwd <- "C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Output VNIR"
    path_cwd
    setwd(path_cwd)
    filename=dir(path = path_cwd)
    
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
      filename2=paste(date[i],'_',genotyp,'_',num_feuil,'_',num_spectra,'.RData',sep='')
      load(filename2)
      datagen[c((1+(num_spectra*(i-1))):(num_spectra*i)),]=data_rand
      date_gen=c(date_gen,rep(i,num_spectra))
    }
    
    if(nrow(data_rand)>ncol(data_rand)){
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
    
    # hist(oh[[1]],breaks=15,main=paste(genotyp,": Taille de la fenêtre =",wchoix + 1))
    # #dev.print(device = png, file = paste(genotyp[g],"_hist_T-w_",h+1,'_composante_',ncomposante,".png",sep=''), width = 600)
    # hist(oh[[2]],breaks=15,main=paste(genotyp,": Taille de la fenêtre =",wchoix + 1))
    # #dev.print(device = png, file = paste(genotyp[g],"_hist_Q_w_",h+1,'_composante_',ncomposante,".png",sep=''), width = 600)
    # 
    # supra=c()
    # for(k in 1:length(boxplot(oh[[1]])$out)){
    #   supra=c(supra,date_plot[which(oh[[1]]==boxplot(oh[[1]])$out[k])+wchoix])
    # }
    # mana=c()
    # for(l in 1:length(boxplot(oh[[2]])$out)){
    #   mana=c(mana,date_plot[which(oh[[2]]==boxplot(oh[[2]])$out[l])+wchoix])
    # }
    
    # bidule=data.frame(date=mm$degresjour[-c(1:(wchoix+1))],Tcarre=oh[[1]])
    # machin=data.frame(Qstat=oh[[2]])
    # 
    # df <- cbind(bidule,machin)
    # 
    # p <- ggplot()
    # p <- p + geom_point(data=df,aes(x=date, y=Tcarre,color="#F8766D"),size=4)
    # p <- p + geom_line(data=df,aes(x=date, y=Tcarre,color="#F8766D"))
    # p <- p + geom_point(data=df,aes(x=date, y=Qstat,color="#00BFC4"),size=4)
    # p <- p + geom_line(data=df,aes(x=date, y=Qstat,color="#00BFC4"))
    # p <- p + ggtitle(paste(genotyp[g],": Taille de la fenêtre =",h + 1))
    # p <- p + xlab("Degrés jour")
    # p <- p + ylab("Statistiques")
    # p <- p + scale_colour_manual(name = "Statistiques", values = c("#F8766D", "#00BFC4"),labels=c("T²","Q"))
    # p <- p + theme(plot.title = element_text(hjust = 0.5))
    # p
    #ggsave(paste(genotyp[g],"_w_",h+1,'_composante_',ncomposante,".png",sep=''), width = 8, height = 6)
    
  }
  result[[uti]] = oh
  T2<-Sys.time() 
}

setwd("~/Thèse/Manip HI2021/Feuilles_test/Résultat")
save(result,file=paste(num_spectra,'.RData',sep=''))

Tdiff= difftime(T1, T2) 
