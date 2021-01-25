# Code for the Bank of England Staff Working Paper 905

This repository includes the code used in the [Bank of England Staff Working Paper 905](http://www.bankofengland.co.uk/working-paper/2021/XXX) "__The more the merrier? Evidence from the global financial crisis on the value of multiple requirements in bank regulation__" by Marcus Buckmann, Paula Gallego Marquez, Mariana Gimpelewicz, Sujit Kapadia and Katie Rismanchi. 

The paper assesses the value of multiple requirements in bank regulation using a rule based methodology. An example of such as rule is the following: 
IF __leverage ratio_ < 3% OR _capital ratio_ <8% THEN predict _failure_, otherwise predict _survival_. To calibrate these thresholded rules, we formulatae a mixed integer program which is shwon in Appendix A.1 of the paper. The code in this repository implements the mixed integer program in R.

Should you have any questions or spot a bug in the code, please send an email to marcus.buckmann@bankofengland.co.uk or raise an issue within the repository.

# Structure of the code

The script _experiment.R_ gives and example how the optimiser can be used, the script _utils.R_ contains a few utility functions and the script _optimiser.R_ implements the optimiser. 


# Disclaimer
This package is an outcome of a research project. All errors are those of the authors. All views expressed are personal views, not those of any employer.

