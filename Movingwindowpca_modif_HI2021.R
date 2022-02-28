#MWPCA -----

rm(list=ls())

window_pca <- function(H,datagen_table=data.frame(datagen),datagen_test=data.frame(datagen),nco=10,date_gen=date_gen,date_gen_test=date_gen,datemax=max(date_gen),rnirmeth=TRUE){
  comp=1
  tcarre_val=c()
  sspe_res=c()
  #faire un test de validation!!!!!!!
  datagen_table_val=datagen_table[sample(rownames(datagen_table),20),]
  
  tcarre=c()
  qstat=c()
  
  for(i in 1:(datemax-H-1)){
    choice=c()
    for(j in comp:(comp+H)){
      choice=c(choice,which(date_gen==j))
    }
    choice_test=which(date_gen_test==comp+H+1)
    datagen_table_train=datagen_table[choice,]
    datagen_table_test=datagen_test[choice_test,]
    res_rnirs=pca(datagen_table_train,datagen_table_test,ncomp=nco)
    pred_testn=res_rnirs$Tu
    
    #save(res_rnirs,file=paste(gen,'_w',H+1,'_iter',i,'_ncomp',nco,'.RData',sep=''))
    
    if(rnirmeth==TRUE){
      tcarre=c(tcarre,mean(scordis(res_rnirs)$du$dstand))
    }else{
      tcarre_val=c()
      
      for(w in 1:nrow(datagen_table_test)){
        tcarre_val=c(tcarre_val,t(t(as.vector(datagen_table_test[w,])))%*%
                   res_rnirs$P%*%
                   pinv(t(res_rnirs$Tr)%*%res_rnirs$Tr)$Xplus%*%
                   t(res_rnirs$P)%*%
                   t(as.vector(datagen_table_test[w,])))
      }
      tcarre=c(tcarre,mean(tcarre_val))
    }
   
    qstat=c(qstat,mean(odis(res_rnirs,datagen_table_train,datagen_table_test)$du$dstand))
    
    
    sspe=c()
    
    #utilisation du test de validation ici
    for(k in 1:nrow(datagen_table_val)){
      #sspe=t(t(as.vector(datagen_table_val[1,])))-t(t(as.vector(datagen_table_val[1,])))%*%res_rnirs$P%*%t(res_rnirs$P)
      
      sspe=c(sspe,abs(t(t(as.vector(datagen_table_val[k,])))-t(t(as.vector(datagen_table_val[k,])))%*%res_rnirs$P%*%t(res_rnirs$P))^2)
      
    }
    
    sspe_res=c(sspe_res,sum(sspe))
    
    tcarre_val=c(tcarre_val,mean(tcarre))
    
    comp=comp+1
  }
  res=list(tcarre,qstat,sspe_res)
  return(res)
}



# ☺☻♥♦♣♠J◘○◙♂♀   ♪♫    ☼►◄↕‼¶§▬↨↑↓→←∟(▲)▼!"#$%&'

