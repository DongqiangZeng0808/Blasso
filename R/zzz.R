



##' @importFrom utils packageDescription
.onAttach <- function(libname, pkgname) {
  pkgVersion <- packageDescription(pkgname, fields="Version")
  msg <- paste0(pkgname, " v", pkgVersion, "  ",
                "For help: https://github.com/DongqiangZeng0808/", "Blasso", "\n\n")

  citation <- paste0(" If you use ", pkgname, " in published research, please cite:\n",
                     "==========================================================================\n",
                     " Macrophage correlates with immunophenotype and predicts anti-PD-L1\n",
                     " response of urothelial cancer. Theranostics 2020; 10(15):7002-7014.",
                     "==========================================================================")

  packageStartupMessage(paste0(msg, citation))
}

