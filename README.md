# Blasso
- Integrating LASSO cox regression and bootstrapping algorithm to find best prognostic features

``` r
# install.packages("devtools")
devtools::install_github("DongqiangZeng0808/Blasso")
```
Main documentation is on the `best_predictor` function in the package:

``` r
help('best_predictor')
```

Example

``` r
res<-best_feature(target = target, features = features,status = "status",time = "time")
head(res)

Citation
---------
Zeng D, Ye Z, Wu J, Zhou R, Fan X, Wang G, Huang Y, Wu J, Sun H, Wang M, Bin J, Liao Y, Li N, Shi M, Liao W. Macrophage correlates with immunophenotype and predicts anti-PD-L1 response of urothelial cancer. Theranostics 2020; 10(15):7002-7014. [doi:10.7150/thno.46176](http://www.thno.org/v10p7002.htm)

Contact
---------
E-mail any questions to dongqiangzeng0808@gmail.com

