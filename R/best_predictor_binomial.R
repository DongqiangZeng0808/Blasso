






#' Using bootstrapping and LASSO algorithm to choose best predictive features
#'
#' @param target_data Data frame contains patient identifier, and target_data
#' @param features Data frame contains patient identifier and variables after feature engineering
#' @param target_data_id identifier of phenotype data
#' @param features_id identifier of feature matrix
#' @param permutation times of iteration
#' @param propotion proportion of patients in each bootstrapping iteration
#' @param nfolds folds to perform cross validation in LASSO
#' @param plot_vars plotting important variables
#' @param response binary variables
#' @param palette plotting palette, default is `#999999`, using `RColorBrewer::display.brewer.all()` to see more options
#' @param show_progress show progress bar
#' @param discrete_x if maximal character length of variables is larger than discrete_x, label will be discrete
#' @param color default is steelblue
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
                                  nfolds = 10,plot_vars = 20, color = "#999999", palette = "Blues",discrete_x = 20){

  tar_fea<-merge(target_data[,c(target_data_id,response)],features,by.x = target_data_id,by.y = features_id,all = F)
  tar_fea<-tibble:: column_to_rownames(tar_fea,var = target_data_id )

  #progress_bar
  pb <-progress:: progress_bar$new(
    format = "  Progressing [:bar] :percent in :elapsed",
    total = permutation, clear = FALSE, width= 100)

  res<-as.list(NULL)

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
    if("(Intercept)"%in%feas){
      feas<-feas[feas!="(Intercept)"]
    }

    feas <- list( names = feas)
    names(feas)<- paste0("res","_",i)
    # myCoefs <-stats::coef(fit, s="lambda.min")
    # feas<-myCoefs@Dimnames[[1]][which(myCoefs!=0 )]
    res<-append(res,feas)
  }

  res1<-unlist(res)
  res1<-as.data.frame(sort(table(res1),decreasing = T))


  if(is.null(color)){
    # RColorBrewer::display.brewer.all()
    # Define the number of colors you want
    colors <-grDevices::colorRampPalette(RColorBrewer:: brewer.pal(8,palette))(plot_vars)
    colors<-rev(colors)
  }else{
    colors<-rep(color, plot_vars)
  }

  if(max(nchar(as.character(res1[1:plot_vars,]$res1)))> discrete_x){
    res1$res1<-gsub(res1$res1, pattern = "\\_",replacement = " ")
    # res1$res1<-gsub(res1$res1, pattern = "\\-",replacement = " ")
  }

  res1$res1<-as.character(res1$res1)
  pp<-ggplot(res1[1:plot_vars,], aes(x= reorder(res1, -Freq), y = Freq, fill = res1)) +
    geom_histogram( stat="identity") +
    geom_hline(aes(yintercept = permutation*0.5), lty= 1,colour="grey",size=0.6)+
    ylim(0,permutation)+
    theme_light()+
    xlab("")+
    theme(axis.text.y=element_text(size=rel(1.5)),
          axis.title = element_text(size=rel(2.5)),
          axis.text.x= element_text(face="plain",size=10,angle=60,hjust = 1,color="black"))+
    scale_fill_manual(values = colors)+
    theme(legend.position = "none")+
    scale_x_discrete(labels=function(x) str_wrap(x, width=35))

  # ggsave(pp,filename ="Frequency_of_variables_choosen_by_lasso.pdf",
  #        width =5+0.1*length(plot_vars) ,height =6.5 )
  print(pp)
  allres<-list("res" = res1,"plot" = pp, res_list = res)
  return(allres)
}
