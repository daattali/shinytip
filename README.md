<p align="center">
  <h3 align="center">shinytip</h3>

  <h4 align="center">
    Simple flexible tootips for Shiny apps
    <br><br>
    <a href="https://daattali.com/shiny/shinytip-demo/">Demo</a>
    &middot;
    by <a href="https://deanattali.com">Dean Attali</a>
  </h4>

  <p align="center">
    <a href="https://github.com/daattali/shinytip/actions">
      <img src="https://github.com/daattali/shinytip/workflows/R-CMD-check/badge.svg" alt="R Build Status" />
    </a>
    <a href="https://cran.r-project.org/package=shinytip">
      <img src="https://www.r-pkg.org/badges/version/shinytip" alt="CRAN version" />
    </a>
  </p>

</p>

---

<!-- badges: start -->
  [![R-CMD-check](https://github.com/daattali/shinytip/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/daattali/shinytip/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

<img src="inst/img/hex.png" width="170" align="right"/>

# shinytip
Simple flexible tootips for Shiny apps

works in rmd
works in dynamic ui (insertUI or renderUI)
works in modals 
works in modules

does not automatically detect the best position
on moble you need to click away rather than click again

Balloon.css make use of pseudo-elements, so if pseudo elements are already in use on an element, the tooltip will conflict with them resulting in potential bugs.


set option for all tooltips using `shinytip.optionname`

cant use HTML but cant use emojis


tippy doesn't work in all the scenarios i tried and doesnt support the optoins i wanted, although it does have a different et of options/methods that shinytip doesnt have so take a look there as well i shinytip doesnt do what you want. it's been in a "warning" state about its api changing for a year


prompter: must add use_prompt()
