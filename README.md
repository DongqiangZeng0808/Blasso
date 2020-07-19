# Blasso
- Integrating LASSO cox regression and bootstrapping algorithm to find best prognostic features

``` r
# install.packages("devtools")
devtools::install_github("DongqiangZeng0808/Blasso")
```
Main documentation is on the `best_predictor` function in the package:

``` r
library("Blasso")
help('best_predictor')
```

Example

``` r
Blasso::features[1:5,1:3]

#               ID  Glycosphosphatidylinositol_PCA   Macrophage_M1_cibersort
# 1 SAM00b9e5c52da9                     -0.3791156              -0.9651426
# 2 SAM0257bbbbd388                      1.3471887              -0.8690076
# 3 SAM025b45c27e05                     -0.1356366              -0.9915367
# 4 SAM032c642382a7                     -1.5168052               0.8050212
# 5 SAM04c589eb3fb3                     -3.0750685               0.6753930

Blasso::target[1:5,]
#                ID status       time
# 1 SAM00b9e5c52da9      1  1.9055441
# 2 SAM0257bbbbd388      1 15.6386037
# 3 SAM025b45c27e05      1  8.7720739
# 4 SAM032c642382a7      1  2.4969199
# 5 SAM04c589eb3fb3      0  0.6899384
res<-best_predictor(target = target, # prognostic variables
                    features = features, #feature matrix
                    status = "status", #name of event in 'target' object
                    time = "time",  #name of follow up time in 'target' object
                    permutation = 1000, # iterations of LASSO cox regression
                    plot_vars = 20)   # visualize result by ggplot2
```

Citation
---------
Zeng D, Ye Z, Wu J, Zhou R, Fan X, Wang G, Huang Y, Wu J, Sun H, Wang M, Bin J, Liao Y, Li N, Shi M, Liao W. Macrophage correlates with immunophenotype and predicts anti-PD-L1 response of urothelial cancer. Theranostics 2020; 10(15):7002-7014. [doi:10.7150/thno.46176](http://www.thno.org/v10p7002.htm)

Contact
---------
E-mail any questions to dongqiangzeng0808@gmail.com

