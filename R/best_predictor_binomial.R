






#' Using bootstrapping and LASSO algorithm to choose best predictive features
#'
#' @param target_data Data frame contains patient identifier, and target_data
#' @param features Data frame contains patient identifier and variables after feature engineering
#' @param target_data_id column name of phenotype data
#' @param features_id column name of feature matrix
#' @param permutation times of iteration
#' @param propotion proportion of patients in each bootstrapping iteration
#' @param nfolds folds to perform cross validation in LASSO
#' @param plot_vars plotting important variables
#' @param response binary variables
#' @param palette plotting palette, using `RColorBrewer::brewer.pal()`
#' @param show_progress show progress bar
#' @param discrete_x if maximal character length of variables is larger than discrete_x, label will be discrete
#'
#' @author Dongqiang Zeng
#'
#' @return
#' @export
#'
#' @examples
#' res<-best_predictor_binomial(target_data = target, features = features,response = "status",nfolds = 10,permutation = 100)
best_predictor_binomial<-function(target_data,response = "response",
                                  features,target_data_id = "ID",features_id ="ID",
                                  show_progress = TRUE,
                                  permutation = 1000,propotion = 0.8,
                                  nfolds = 10,plot_vars = 20,palette = "Blues",discrete_x = 20){

  tar_fea<-merge(target_data[,c(target_data_id,response)],features,by.x = target_data_id,by.y = features_id,all = F)
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
    response_factor<-as.factor(tar_fea[index,response])
    # rt<-as.data.frame(tar_fea[index,c("ID",response)])
    fea_matrix<-as.matrix(as.data.frame(tar_fea[index,2:ncol(tar_fea)]))
    fit<-glmnet::cv.glmnet(fea_matrix, response_factor, family="binomial",
                           type.measure = "mse", maxit = 1000,
                           nfolds = nfolds,alpha = 1)

    coefs <- coef(fit$glmnet.fit, s=fit$lambda.min)
    # active.coef <- coefs[which(coefs[,1]!=0)]
    feas <- row.names(coefs)[which(coefs[,1]!=0)]
    # myCoefs <-stats::coef(fit, s="lambda.min")
    # feas<-myCoefs@Dimnames[[1]][which(myCoefs!=0 )]
    res<-append(res,feas)
  }
  res<-as.data.frame(sort(table(res),decreasing = T))
  if("(Intercept)"%in%res$res){
    res<-res[-which(res$res=="(Intercept)"),]
  }
  # Define the number of colors you want
  # RColorBrewer::display.brewer.all()
  colors <-grDevices::colorRampPalette(RColorBrewer::brewer.pal(8, palette))(plot_vars)
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
