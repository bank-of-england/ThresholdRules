normalise <- function(e) {
  #' normalise data set to range [0,1] 
  #' @param e input data set. The first column is the class label and is not normalised. 
  out <- apply(e[-1], 2, normaliseVar)
  return(cbind(e[1], out))
}

normaliseVar <- function (x) {
  #' normalises variable x to range [0,1] 
  #' @param x numeric variable  
  minx <- min(x, na.rm=TRUE)
  maxx <- max(x, na.rm=TRUE)
  if (maxx-minx == 0) {
    x <- (x - minx)
  } else {
    x <- (x - minx) / (maxx - minx)
  }
  return (x)
}


predictRule <- function(rule, data_input){
  #' Makes prediction according to a rule.
  #' @param rule output of optimizeRule function. 
  #' @param data_input data.frame containing the test data for which the predictions should be obtained.
  #' @return vector of predictions.
  predict_per_rule <- sapply(rule, function(a) eval(parse(text = paste0("data_input$", a))))
  if(!is.matrix(predict_per_rule)) 
    predict_per_rule <- t(as.matrix(predict_per_rule))
  fit <- 1*(rowSums(predict_per_rule) >= 1)
  names(fit) <- rownames(data_input)
  return(fit)
}