




#' Using bootstraping and LASSO algorithm to choose best prognostic features
#'
#' @param target Data frame contains patient identifer, survival time and survival event = 0/1
#' @param features Data frame contains patient identifer and variables after feature engineering
#' @param permutation times of iteration
#' @param status column name of survival event
#' @param time column name of survival time
#' @param target_id column name of phenotype data
#' @param features_id column name of feature matrix
#' @param propotion propotion of patients in each bootstraping iteration
#' @param nfolds folds to perform cross validataion in LASSO

#' @return variables with frequency
#' @export
#'
#' @examples
#' res<-best_feature(target = target, features = features,status = "status",time = "time")

best_predictor<-function(target,features,status,time,target_id = "ID",features_id ="ID",
                       permutation = 1000,propotion = 0.8,nfolds = 10,plot_vars = 20){

  tar_fea<-merge(target[,c(target_id,status,time)],features,by.x = target_id,by.y = features_id,all = F)
  tar_fea<-tibble:: column_to_rownames(tar_fea,var = target_id )

  res<-as.character()
  for(i in 1:permutation){
    index<-floor(runif(floor(dim(tar_fea)[1])*propotion,1,dim(tar_fea)[1]))

    rt<-as.matrix(tar_fea[index,1:2])
    fea_matrix<-as.matrix(as.data.frame(tar_fea[index,3:ncol(tar_fea)]))
    fit2<-glmnet:: cv.glmnet(fea_matrix, rt, family="cox", maxit = 1000,nfolds = nfolds,alpha=1)
    myCoefs <- coef(fit2, s="lambda.min")
    feas<-myCoefs@Dimnames[[1]][which(myCoefs != 0 )]
    res<-append(res,feas)
  }
  res<-as.data.frame(sort(table(res),decreasing = T))

  # Define the number of colors you want
  colors <-grDevices::colorRampPalette(brewer.pal(8, "Blues"))(plot_vars)
  colors<-rev(colors)
  pp<-ggplot(res[1:plot_vars,], aes(fill=res, y=Freq, x=res)) +
    geom_histogram( stat="identity") +
    geom_hline(aes(yintercept = permutation*0.5), lty= 1,colour="grey",size=0.6)+
    ylim(0,permutation)+
    theme_light()+
    xlab("")+
    theme(axis.text.y=element_text(size=rel(1.5)),
          axis.text.x= element_text(face="plain",size=7,angle=60,hjust = 1,color="black"))+
    scale_fill_manual(values = colors)+theme(legend.position = "none")

  ggsave(pp,filename ="Frequency_of_variables_choosen_by_lasso.pdf",
         width =5+0.1*length(plot_vars) ,height =6.5 )

  return(res)
}


