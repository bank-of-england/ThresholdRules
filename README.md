# Code for the Bank of England Staff Working Paper 905

This repository includes the code used in the [Bank of England Staff Working Paper 905](http://www.bankofengland.co.uk/working-paper/2021/XXX) "__The more the merrier? Evidence from the global financial crisis on the value of multiple requirements in bank regulation__" by Marcus Buckmann, Paula Gallego Marquez, Mariana Gimpelewicz, Sujit Kapadia and Katie Rismanchi. 

The paper assesses the value of multiple requirements in bank regulation using a rule based methodology. An example of such as rule is the following: 
IF __leverage ratio_ < 3% OR _capital ratio_ <8% THEN predict _failure_, otherwise predict _survival_. To calibrate these thresholded rules, we formulatae a mixed integer program which is shwon in Appendix A.1 of the paper. The code in this repository implements the mixed integer program in R.

Should you have any questions or spot a bug in the code, please send an email to marcus.buckmann@bankofengland.co.uk or raise an issue within the repository.


# Prerequisites 
The code has been developed and used under ```R``` 3.6.2 

The script _requirements.R_ in the _setup_ folder installs all necessary ```R``` packages.
 

# Structure of the code


The script _experiment.R_ gives and example how the optimiser can be used, the script _utils.R_ contains a few utility functions and the script _optimiser.R_ implements the optimiser. 



## Estimating the prediction models
The paper is based on two main empirical experiments: cross-validation and forecasting. These experiments are run using the respective ```Python``` scripts in the _experiments_ folder.
In these scripts, the user can specify the models to be trained, the variables to be included, and how the variables should be transformed. The results of the experiments are written to the _results_ folder. To obtain stable perfomance estimates, we repeat the experiments many times. For this repository, we repeated the 5-fold cross-validation 10 times. Each _pickle_ file in the _results_ folder contains the results of one iteration. Each iteration uses a different random seed and therefore partitions the data into a training and test set differently. 

The experiments do not need to be run at once. The user can terminate the experiments after a certain number of iterations and run more iterations at another point in time. Then, new pickle files will be added to the folder.
The _.txt_ files in the _results_ folder are written based on the information contained in all the _pickle_ files and are updated after each iteration.

The key files in the _results_ folder are the following:
The _data[...].txt_ contains the dataset that is used in the experiment. This is not the raw dataset, rather all transformations and exclusions of data points have been applied.
- The _all_pred[...].txt_ contains the predictions for each observations, algorithm and iteration. 
- The _shapley_append[...].txt_ show the Shapley values for each observation, predictor and iteration. For each algorithm tested, an individual file is created.
- The _shapley_mean[...].txt_ file, shows the average Shapely values for each observation and predictor, averaged across all observations. For each algorithm tested, an individual file is created.
- The _mean_fold[...].txt_ shows the mean performance achieved in the individual folds. The files _mean_iter[...].txt_ and _mean_append[...].txt_ are similar. They just average the results differently. The former measures the performance for each iteration and averages the performance measures across iterations. The latter first averages the predicted values across all observations and then computes the performance on these averaged predicted values. 
- The files _se_fold[...].txt_ and _se_iter[...].txt_ show the standard errors of the respective performance results.



# Disclaimer
This package is an outcome of a research project. All errors are those of the authors. All views expressed are personal views, not those of any employer.

