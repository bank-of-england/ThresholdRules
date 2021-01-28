# Code for the Bank of England Staff Working Paper 905

This repository contains the implementation of the model used in the upcoming [Bank of England Staff Working Paper 905](http://www.bankofengland.co.uk/working-paper/2021/the-more-the-merrier-evidence-from-the-global-financial-crisis) "__The more the merrier? Evidence from the global financial crisis on the value of multiple requirements in bank regulation__" by Marcus Buckmann, Paula Gallego Marquez, Mariana Gimpelewicz, Sujit Kapadia and Katie Rismanchi. 

The paper assesses the value of multiple requirements in bank regulation using a rule-based methodology. An example of such as rule is the following: 
IF _leverage ratio_ < 3% OR _capital ratio_ <8% THEN predict _failure_, otherwise predict _survival_. To calibrate these rules, we formulate a mixed integer program which is shown in Appendix A.1 of the paper. The code in this repository implements the mixed integer program in R. Given a binary outcome variable codes as 0/1 (bank failed = 1, bank survived =0) the model finds the threshold values on the metrics (e.g. leverage ratio, capital ratio) that miminise the false alarm rate for a given target hit rate specified by the user. For example, the model finds the optimal combination of thresholds that minimises the proportion of survived banks incorrectly flagged as failed, while being constrained to correctly classify 80% of the failed banks. The model assumes that all metrics are coded such that lower values indicate a higher probability of the outcome being 1.  

Should you have any questions or spot a bug in the code, please send an email to marcus.buckmann@bankofengland.co.uk or raise an issue within the repository.

## Structure of the code

The script _experiment.R_ shows how the model is used, the script _utils.R_ contains a few utility functions and the script _model.R_ implements the mixed integer program. The _requirements.txt_ file lists the R package required to use the optimiser.


## Disclaimer
This repository is an outcome of a research project. All errors are those of the authors. All views expressed are personal views, not those of the Bank of England.

