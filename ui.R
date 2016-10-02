library(shiny)
shinyUI(pageWithSidebar(
    headerPanel("Air Quality Measurements in New York City (1973)"),
    sidebarPanel(
        selectInput("variables",
                    "Variable:",
                    choices = c("Ozone",
                                "Solar Radiation",
                                "Wind",
                                "Temperature"
                                )
                    ),

        dateInput("from",
                  "from:",
                  value = "1973-05-01",
                  min = "1973-05-01",
                  max = "1973-09-30"
                  ),

        dateInput("to",
                  "to:",
                  value = "1973-09-30",
                  min = "1973-05-01",
                  max = "1973-09-30"
                  ),

        checkboxInput("trend_line",
                      "Compute trend",
                      value = FALSE
        ),

        numericInput("lag",
                     "Window Size:",
                     value = 3,
                     min = 3,
                     max = 10,
                     step = 1)


    ),
    mainPanel(
        plotOutput("line_graph")
    )
))
