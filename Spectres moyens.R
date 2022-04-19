rm(list=ls())

library("R.matlab")
library("rnirs")

setwd("~/Thèse/Manip HI2021/Feuilles_test")

setwd("~/Thèse/Manip HI2021/Feuilles_test/Output VNIR corr")
path_cwd <- "C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Output VNIR corr"
path_cwd

filename_tot=dir(path = path_cwd)

chemin='C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Spectres moyens'
  
test_file <- function(path_file){
  if(file.exists(path_file)==T){
    return('Bon fichier')
  }else{
    dir.create(path_file)
  }
}

ind='26_G'
num_feuil='3'
filename=c()
for(tot in 1:length(filename_tot)){
  if(substr(filename_tot[tot],10,13)==ind & substr(filename_tot[tot],56,56)==num_feuil){
    filename=c(filename,filename_tot[tot])
  }
}
truc=c()

for(i in 1:length(filename)){
  setwd(path_cwd)
  
  data=readMat(filename[i])
  
  chem2=paste('/',substr(filename[i],10,13),sep='')
  chemfinal=paste(chemin,chem2,sep='')
  test_file(chemfinal)
  
  setwd(chemfinal)

  data_mean=colMeans(data$matr)
  truc=c(truc,nrow(data$matr))
  samp=sample(c(1:nrow(data$matr)),100)
  data_rand=data$matr[samp,]
  # nomplot=paste(substr(filename[i],10,13),substr(filename[i],55,56),'_',substr(filename[i],1,8),'.jpg',sep='')
  # jpeg(nomplot, width = 350, height = 350)
  plotsp(data_mean,main=paste(substr(filename[i],1,13),substr(filename[i],56,56),sep='_'))
  # dev.off()
  # nomplot_rand=paste(substr(filename[i],10,13),substr(filename[i],55,56),'_',substr(filename[i],1,8),'100','.jpg',sep='')
  # jpeg(nomplot_rand, width = 350, height = 350)
  plotsp(data_rand,main=paste(substr(filename[i],1,13),substr(filename[i],56,56),sep='_'))
  # dev.off()

  
}

hist(truc)

# data=readMat(filename[12])
# mat=pca(data$matr,ncomp=215)
# plotxy(mat$Tr[,c(1,2)], zeroes = TRUE)
# plotsp(data$matr[-c(which(mat$Tr[,1]>2)),])
# plotsp(data$matr[c(which(mat$Tr[,1]>2)),],col='red',add=TRUE)

setwd(path_cwd)
data1=readMat(filename[16])
data2=readMat(filename[17])
data3=readMat(filename[18])
library(rnirs)
library(ggplot2)
datab=snv(rbind(data1$matr,data2$matr))
mod=pca(datab,snv(data3$matr),ncomp=400)
Tr <- mod$Tr
Tu <- mod$Tu
T <- rbind(datab, data3$matr)

T <- rbind(Tr, Tu)
row.names(T) <- 1:nrow(T)
group <- c(rep(1, nrow(Tr)), rep(2, nrow(Tu)))
#plotxy(T, col=group ,pch = 16, zeroes = TRUE)
truc=scordis(mod)
hist(truc$du$dstand,breaks=100)
#plotxy(T, group = group, labels = TRUE, zeroes = TRUE, alpha.f = 1)

z <- mod$explvar
barplot(100 * z$pvar, names.arg = paste("comp", z$ncomp), 
        ylab = "Pct. of variance explained")

