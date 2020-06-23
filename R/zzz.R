



##' @importFrom utils packageDescription
.onAttach <- function(libname, pkgname) {
  pkgVersion <- packageDescription(pkgname, fields="Version")
  msg <- paste0(pkgname, " v", pkgVersion, "  ",
                "For help: https://github.com/DongqiangZeng0808/", "mUC-M1", "\n\n")

  citation <- paste0(" If you use ", pkgname, " in published research, please cite:\n",
                     " Zeng D, Ye Z, Wu J, Zhou R, Fan X, Wang G, Huang Y, Wu J, Sun H, Wang M, Bin J, Liao Y, Li N, Shi M, Liao W. Macrophage correlates with immunophenotype and predicts anti-PD-L1 response of urothelial cancer. Theranostics 2020; 10(15):7002-7014.")

  packageStartupMessage(paste0(msg, citation))
}

