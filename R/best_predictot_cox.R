








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
#' @param palette plotting palette, using `RColorBrewer::display.brewer.all()`
#' @param color default is steelblue
#' @param show_progress show progress bar
#' @param discrete_x if maximal character length of variables is larger than discrete_x, label will be discrete
#' @author Dongqiang Zeng
#' @return variables with frequency, plot and list
#' @export
#'
#' @examples
#' data("target")
#' data("features")
# res<-best_predictor_cox(target_data = target, features = features,status = "status",time = "time",permutation =100)

best_predictor_cox<-function(target_data, features, status, time,target_data_id = "ID", features_id ="ID",
                             permutation = 1000, propotion = 0.8, nfolds = 10,
                             plot_vars = 20, color = "steelblue", palette = "Blues",
                             show_progress = TRUE, discrete_x = 20){

  target_data<-as.data.frame(target_data)
  colnames(target_data)[which(colnames(target_data)==time)]<-"time"
  colnames(target_data)[which(colnames(target_data)==status)]<-"status"

  tar_fea<-merge(target_data[,c(target_data_id,"status","time")],features,
                 by.x = target_data_id,by.y = features_id,all = F)

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

    rt<-as.matrix(tar_fea[index,1:2])
    fea_matrix<-as.matrix(as.data.frame(tar_fea[index,3:ncol(tar_fea)]))
    fit<-glmnet::cv.glmnet(fea_matrix, rt, family="cox",
                           type.measure = "deviance",
                           maxit = 1000,nfolds = nfolds,alpha=1)

    coefs <- coef(fit$glmnet.fit, s=fit$lambda.min)
    # active.coef <- coefs[which(coefs[,1]!=0)]
    feas <- row.names(coefs)[which(coefs[,1]!=0)]

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
    res1$res1<-gsub(res1$res1,pattern = "\\_",replacement = " ")
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


