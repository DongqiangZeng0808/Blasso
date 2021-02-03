


#' Using bootstrapping and LASSO algorithm to choose best prognostic features
#'
#' @param target_data Data frame contains patient identifier, survival time and survival event = 0/1
#' @param features Data frame contains patient identifier and variables after feature engineering
#' @param permutation times of iteration
#' @param status column name of survival event
#' @param time column name of survival time
#' @param target_data_id column name of phenotype data
#' @param features_id column name of feature matrix
#' @param propotion proportion of patients in each bootstrapping iteration
#' @param nfolds folds to perform cross validation in LASSO
#' @param palette plotting palette, using `RColorBrewer::brewer.pal()`
#' @param show_progress show progress bar
#' @param discrete_x if maximal character length of variables is larger than discrete_x, label will be discrete
#' @author Dongqiang Zeng
#' @return variables with frequency
#' @export
#'
#' @examples
#' data("target")
#' data("features")
# res<-best_predictor_cox(target_data = target, features = features,status = "status",time = "time",permutation =100)

best_predictor_cox<-function(target_data,features,status,time,target_data_id = "ID",features_id ="ID",
                       permutation = 1000,propotion = 0.8,nfolds = 10,plot_vars = 20,palette = "Blues",show_progress = TRUE,discrete_x = 20){

  tar_fea<-merge(target_data[,c(target_data_id,status,time)],features,by.x = target_data_id,by.y = features_id,all = F)
  tar_fea<-tibble:: column_to_rownames(tar_fea,var = target_data_id )

  #progress_bar
  pb <-progress:: progress_bar$new(
    format = "  Progressing [:bar] :percent in :elapsed",
    total = permutation, clear = FALSE, width= 100)

  res<-as.character(NULL)
  for(i in 1:permutation){

    if(show_progress){
      pb$tick()
      Sys.sleep(1 / 100)
    }

    index<-floor(runif(floor(dim(tar_fea)[1])*propotion,1,dim(tar_fea)[1]))

    rt<-as.matrix(tar_fea[index,1:2])
    fea_matrix<-as.matrix(as.data.frame(tar_fea[index,3:ncol(tar_fea)]))
    fit<-glmnet::cv.glmnet(fea_matrix, rt, family="cox",
                           type.measure = "deviance",
                           maxit = 1000,nfolds = nfolds,alpha=1)

    coefs <- coef(fit$glmnet.fit, s=fit$lambda.min)
    # active.coef <- coefs[which(coefs[,1]!=0)]
    feas <- row.names(coefs)[which(coefs[,1]!=0)]
    # myCoefs <-stats::coef(fit, s="lambda.min")
    # feas<-myCoefs@Dimnames[[1]][which(myCoefs!=0 )]
    res<-append(res,feas)
  }
  res<-as.data.frame(sort(table(res),decreasing = T))

  # RColorBrewer::display.brewer.all()
  # Define the number of colors you want
  colors <-grDevices::colorRampPalette(RColorBrewer:: brewer.pal(8,palette))(plot_vars)
  colors<-rev(colors)


  if(max(nchar(as.character(res[1:plot_vars,]$res)))> discrete_x){
    res$res<-gsub(res$res,pattern = "\\_",replacement = " ")
  }

  pp<-ggplot(res[1:plot_vars,], aes(fill=res, y=Freq, x=res)) +
    geom_histogram( stat="identity") +
    geom_hline(aes(yintercept = permutation*0.5), lty= 1,colour="grey",size=0.6)+
    ylim(0,permutation)+
    theme_light()+
    xlab("")+
    theme(axis.text.y=element_text(size=rel(1.5)),
          axis.text.x= element_text(face="plain",size=10,angle=60,hjust = 1,color="black"))+
    scale_fill_manual(values = colors)+theme(legend.position = "none")+
    scale_x_discrete(labels=function(x) str_wrap(x, width=35))

  # ggsave(pp,filename ="Frequency_of_variables_choosen_by_lasso.pdf",
  #        width =5+0.1*length(plot_vars) ,height =6.5 )
  print(pp)
  res<-list("res" = res,"plot" = pp)
  return(res)
}


