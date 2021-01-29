
optimiseRule <- function(data_input,
                         minimum_hit_rate = .5,
                         solver = "lpsolve", 
                         error_weights = c(1, 100),
                         regularise_threshold = 0.1) {
  #' Optimizses thresholded rule
  #' @param data_input data.frame. The first column is the outcome variable, the remaining columns are the metrics for which the thresholds are calibrated.
  #' @param minimum_hit_rate float. Minimum hit rate that the model is constrained to achieve across the input data.
  #' @param solver string. Solver that is used to obtain a solution. Options are 'lpsolve'and 'glpk'.
  #' @param error_weights float vector of length 2. It specifies how the model weights the hit rate and true negative rate. Default values are c(1, 100), i.e. the true negative rate has a 100 x higher weight than the hit rate.
  #' @param regularise_threshold float. If > 0, higher thresholds are penalized. The higher the value the higher the penalty. The default value is small (0.1) to avoid that smaller threshold are traded for accuracy.
  #' @return rule model
  
  data_input_normalised <- normalise(data_input) # normalise all variables to values between 0 and 1.
  data_input_normalised <- round(data_input_normalised,5) 
  
  x <- as.matrix(data_input_normalised)[, -1, drop = F]
  n_objects <- nrow(x)
  n_features <-ncol(x)
  class_label <- data_input_normalised[,1] * 2 - 1 # for convenience the class label is recoded from {0,1} to {-1,1}
  n_objects_pos <- sum(class_label == 1)
  n_objects_neg <-n_objects - n_objects_pos
  
  # list variables in the mixed integer program
  thresholds <- rep("C", n_features) # thresholds
  Z <- rep("B",n_objects * n_features) # indicating for each object whether test (eg. lr < 0.5) is true
  epsilon <- rep("B", n_objects) # vector indicating whether prediction is wrong
  metrics <- rep("C", 2) # hit rate, true negative rate (1 - false alarm rate)
  all_variables <- c(thresholds, Z, epsilon, metrics) # hit, false
  n_variables <- length(all_variables)# number of all variables
  
  # compute constants required for MIP formulation
  delta <- rep(NA, n_features)
  for(j in 1:n_features){
    a <- unique(sort(x[,j]))
    a <- a[a <= 1]
    delta[j] <- min(a[-1]-head(a,-1))
  }
  delta_max <- max(delta)
  M <- 1 + delta_max # constant
  
  # initialise constraint matrix (mat), right-hand side of the equations (rhs)
  # and the comparison operator (comp)
  n_constraints <- n_objects * n_features * 2 + 2 *n_objects + 3
  mat <- array(NA, dim = c(n_constraints, n_variables))
  rhs <- rep(NA, nrow(mat))
  comp <- rep(NA, nrow(mat))
  
  
  # Equations A.5 and A.5:
  counter <- 1
  for(d in 1:n_features){
    for(o in 1:n_objects){
      
      temp <- rep(0, n_variables)
      temp[d] <- -1 
      temp[length(thresholds) + n_objects * (d-1) + o] <- M # z indicator
      mat[counter,] <- temp
      rhs[counter] <- -1 * (x[o,d])
      comp[counter] <- "G"
      counter <- counter + 1
      
      temp <- rep(0, n_variables)
      temp[d] <- -1 
      temp[length(thresholds) + n_objects*(d-1) + o] <- M # z indicator
      mat[counter,] <- temp
      rhs[counter] <-  M - 1*(x[o,d] + delta[d])
      comp[counter] <- "L"
      counter <- counter + 1
    }
    
  }
  
  
  # Equations A.7 and A.8:
  for(o in 1:n_objects){
    
    temp <- rep(0, n_variables)
    temp[length(thresholds) + n_objects * (1:n_features-1) + o] <- class_label[o] 
    temp[length(thresholds) + length(Z) + o] <- n_features
    mat[counter,] <- temp
    rhs[counter] <- .5 * class_label[o]
    comp[counter] <- "G"
    counter <- counter + 1
    
    temp <- rep(0, n_variables)
    temp[length(thresholds) + n_objects*(1:n_features - 1) + o] <- class_label[o] 
    temp[length(thresholds) + length(Z) + o] <- n_features 
    mat[counter,] <- temp
    rhs[counter] <- .5 * class_label[o] + n_features
    comp[counter] <- "L"
    counter <- counter + 1
    
  }
  
  # Equation A.3
  temp <- rep(0, n_variables)
  temp[length(thresholds) + length(Z) + length(epsilon)  +  1] <- n_objects_pos
  temp[length(thresholds) + length(Z) + 1:length(epsilon)] <- (class_label + 1) / 2
  mat[counter,] <- temp
  rhs[counter] <- n_objects_pos
  comp[counter] <- "E"
  
  counter <- counter + 1
  
  # Equation A.4
  temp <- rep(0, n_variables)
  temp[length(thresholds) + length(Z) + length(epsilon)  + 2] <- n_objects_neg 
  temp[length(thresholds) + length(Z) + 1:length(epsilon)] <- 1- (class_label+1)/2
  mat[counter,] <- temp
  rhs[counter] <- n_objects_neg
  comp[counter] <- "E"
  
  counter <- counter + 1
  
  # Equation A.2
  temp <- rep(0, n_variables)
  temp[length(thresholds) + length(Z) + length(epsilon) + 1] <- 1
  mat[counter,] <- temp
  rhs[counter] <- n_objects_neg
  comp[counter] <- "G"
  
  mat[counter,] <- temp
  rhs[counter] <- minimum_hit_rate
  dir <- c(dir,"G")
  
  # objective function
  temp <- rep(0, n_variables)
  temp[(n_variables - 1:0)] <- error_weights
  temp[1:length(thresholds)] <- -regularise_threshold
  objective_function <- temp
  
  
  # set lower (lowb) and upper (upb) limits for variables
  lower_bounds <- rep(0, n_variables)
  upper_bounds <- rep(1, n_variables)
  
  
  if(solver == "glpk"){
    out <- Rglpk::Rglpk_solve_LP(obj = objective_function,
                                 mat = mat, 
                                 dir = plyr::mapvalues(comp, from = c("G", "L", "E"), to = c(">=", "<=", "==")),
                                 rhs = rhs,
                                 # bounds = list(upper = upper_bounds, lower = lower_bounds), 
                                 types = all_variables, 
                                 max = TRUE, 
                                 control = list("verbose" = F))
    result <- out$solution
  }
  
  if(solver == "lpsolve"){
    model <- lpSolveAPI::make.lp(n_constraints, n_variables)
    lpSolveAPI::lp.control(model, sense='max')
    lpSolveAPI::set.constr.type(model,
                             types= plyr::mapvalues(comp, from = c("G", "L", "E"), to = c(">=", "<=", "=")))
    lpSolveAPI::set.rhs(model, b = rhs)
    lpSolveAPI::set.bounds(model, lower = lower_bounds, upper = upper_bounds, columns = 1:n_variables)
    variable_types <- ifelse(all_variables =="B", "binary", "real")
    
    for(r in 1:n_variables){
      lpSolveAPI::set.column(model, r, mat[,r])
      lpSolveAPI::set.type(model, r, type = variable_types[r])
    }
    lpSolveAPI::set.objfn(model, objective_function)
    status <- solve(model)
    result <- lpSolveAPI::get.variables(model)
  }
  
  
  # extract thresholds from result 
  thresholds_learned <- round(result[1:n_features],5)
  
  index_max <- thresholds_learned > 1
  index_min <- thresholds_learned < 0
  
  for(t in 1:n_features){ # smooth thresholds such that they lie between observed values.
    if(thresholds_learned[t]>0){ 
      unique_values <- sort(unique(c(round(x[,t],5))))
      dif <- unique_values - thresholds_learned[t]
      index <- which(dif == min(dif[dif>=0]))
      thresholds_learned[t] <- (unique_values[index] + (unique_values[index-1]))/2
    }
  }
  thresholds_learned[index_max] <- 1
  thresholds_learned[index_min] <- 0
  
  # transform threshold to original value range from data_input
  min_x <- apply(data_input[,-1, drop = F],2,min, na.rm = T) 
  max_x <- apply(data_input[,-1, drop = F],2,max, na.rm = T)
  
  thresholds_transformed <- thresholds_learned*(max_x-min_x) + min_x
  
  # prepare output of model
  output <- list()
  counter <- 1
  for(d in 1:n_features){
    output[[counter]] <- paste(colnames(data_input)[-1][d], 
                               "<",
                               thresholds_transformed[d]
    )
    counter <- counter + 1
  }
  attr(output,"thresholds") <- thresholds_transformed
  return(output)
}

