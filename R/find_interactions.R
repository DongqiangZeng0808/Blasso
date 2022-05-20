


#' Find interactions
#'
#' @param input list of variables chosen by the model
#' @param num_target default is 2
#'
#' @return
#' @export
#'
#' @examples
#' res<-best_predictor_binomial(target_data = target, features = features,response = "status",nfolds = 10,permutation = 100)
#' inter<-find_interaction(input = res$res_list, num_target = 2)
find_interaction<-function(input, num_target = 2 ){


  res_list<-input
  mycombn<-function(x, m = num_target){
    res<-combn(x, m = m, simplify = F)
    return(res)
  }
  res_map<- purrr:: map(res_list, mycombn)

  res_data<-data.frame("variables" = NA, "count" = NA)
  #######################################
  for (j in 1:length(res_map)) {

    bridge<-res_map[[j]]

    res_data_i<-data.frame("variables" = NA, "count" = NA)
    for (i in 1:length(bridge)) {

      res_target<-data.frame("variables" = NA, "count" = NA)
      target<-as.character(bridge[[i]])
      res_target$variables<-paste0(target, collapse = " & ")

      cal_count<-function(list){
        logic<- all(target%in%list)
        return(logic)
      }
      count<-sum(unlist(map(res_list, cal_count))==TRUE)
      res_target$count<-count

      res_data_i<-rbind(res_data_i, res_target)
    }

    res_data<-rbind(res_data, res_data_i)

  }

  res_data<-res_data[!is.na(res_data$variables),]
  res_data<-res_data[!duplicated(res_data$variables),]
  res_data<-res_data[order(res_data$count, decreasing = T),]
  return(res_data)

}



