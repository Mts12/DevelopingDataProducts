library(shiny)
library(zoo)

# Create date column (from 1973-05-01 to 1973-09-30)
origin <- as.Date("1973-05-01")
air_data       <- airquality
air_data$date  <- 0:(length(airquality$Day)-1) + origin

# Fill NAs
air_data$Ozone   <- na.approx(air_data$Ozone)
air_data$Solar.R <- na.approx(air_data$Solar.R)

###
# getPlotData
# This function select variables in accordance with user's input
#
getPlotData <- function(indx_from, indx_to, variable){
    mask <- air_data$date >= indx_from & air_data$date <= indx_to
    plot_data <- air_data[mask, ]

    if     (variable == "Ozone"          ){ return (plot_data$Ozone  ) }
    else if(variable == "Solar Radiation"){ return (plot_data$Solar.R) }
    else if(variable == "Wind"           ){ return (plot_data$Wind   ) }
    else if(variable == "Temperature"    ){ return (plot_data$Temp   ) }
}

###
# getPlotLabel
# This function select ylab of plot() in accordance with user's input
#
getPlotLabel <- function(variable){
    if     (variable == "Ozone"          ){ return ("Ozone (ppb)"            ) }
    else if(variable == "Solar Radiation"){ return ("Solar Radiation (lang)" ) }
    else if(variable == "Wind"           ){ return ("Wind (mph)"             ) }
    else if(variable == "Temperature"    ){ return ("Temperature (degrees F)") }
}

###
# smoothTS
# Comoute moving average
# When lag is longer than data, simply return first data
#
smoothTS <- function(dates, data, lag){


    if(length(dates) >= lag){

        # Compute moving average
        moving_average <- filter(data, rep(1, lag)/lag)

        # Combine filtered data with dates and remove NAs
        ret_frame <- data.frame(x=dates, y=moving_average)
        ret_frame <- ret_frame[!is.na(ret_frame$y),]
    }
    else{
        # When lag is longer than data, simply return first data
        ret_frame <- data.frame(x=c(dates[1], dates[1]), y=c(data[1], data[1]))
    }
    return(ret_frame)
}

###
# shinyServer
# main function
#
shinyServer(
    function(input, output) {
        output$line_graph <- renderPlot({

            # Check if starting date priors to ending date
            if(input$from <= input$to){
                indx_from <- input$from
                indx_to   <- input$to
            }
            else{
                indx_from <- input$from
                indx_to   <- input$from
            }

            # create data to plot: x=dates, y=selected variable
            x <- seq(indx_from, indx_to, by="days")
            y <- getPlotData(indx_from, indx_to, input$variables)

            plot(x, y,
                 xlab = "Date",
                 ylab = getPlotLabel(input$variables),
                 type = "l")

            if(input$trend_line==TRUE){
                trend <- smoothTS(x, y, input$lag)
                lines(trend$x, trend$y, col="blue",lwd=2)
            }

            legend("topleft",
                   legend=c(input$variables,"Trend"),
                   col=c("black", "blue"),
                   lty=c(1,1), lwd=c(1,2),
                   bg="transparent")

        })
    }
)
