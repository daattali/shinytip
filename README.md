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

cant use HTML but can use emojis


tippy doesn't work in all the scenarios i tried and doesnt support the optoins i wanted, although it does have a different et of options/methods that shinytip doesnt have so take a look there as well i shinytip doesnt do what you want. it's been in a "warning" state about its api changing for a year


prompter: must add use_prompt(), must define a position
