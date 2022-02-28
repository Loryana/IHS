rm(list=ls())

library("R.matlab")
library("rnirs")

setwd("~/Thèse/Manip HI2021/Feuilles_test")

setwd("~/Thèse/Manip HI2021/Feuilles_test/Output VNIR")
path_cwd <- "C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Output VNIR"
path_cwd

filename=dir(path = path_cwd)

chemin='C:/Users/heloise.villesseche/Documents/Thèse/Manip HI2021/Feuilles_test/Spectres 100'

test_file <- function(path_file){
  if(file.exists(path_file)==T){
    return('Bon fichier')
  }else{
    dir.create(path_file)
  }
}


for(i in 1:length(filename)){
  setwd(path_cwd)
  
  data=readMat(filename[i])
  samp=sample(c(1:nrow(data$matr)),100)
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
                  '100','.RData',sep='')
  save(data_rand,file=name_file)
}