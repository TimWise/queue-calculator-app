
library(shiny)

library(scales)
library(ggplot2)
library(Cairo)
library(queueing)

rho     <- seq (0.01, 0.99, by = 0.01)
nPoints <- length(rho)

yMax <- 16
yBreaks <- seq(0, 128, by = 2)
yLabels <- sprintf('%sx', yBreaks)
xBreaks <- seq(0, 1, by = 0.2)

formatYLabel <- function(l) {
  sprintf('%sx', l)
}

shinyServer(
  function(input, output) {
    
    # React to changes in the Number of Servers 
    #
    N <- reactive({ input$nServers })
    
    # Create the queue networks for each of the three systems
    # 
    gsQueue <- reactive({ QueueingModel(NewInput.MM1(lambda = rho,       mu = 1)) })
    btQueue <- reactive({ QueueingModel(NewInput.MMC(lambda = rho * N(), mu = 1, c = N())) })
    ssQueue <- reactive({ QueueingModel(NewInput.MM1(lambda = rho * N() ,mu = 1 * N())) })
    
    # Watch for zoom actions in chart
    # 
    selectedRange <- reactiveValues(x = c(0, 1), 
                                    y = c(0, yMax))
    observeEvent(
      input$rspTimeChart.dblClick, {
        
        b <- input$rspTimeChart.brush
        
        if (!is.null(b)) {
          selectedRange$x <- c(b$xmin, b$xmax)
          selectedRange$y <- c(b$ymin, b$ymax)
          
        } else {
          selectedRange$x <- c(0, 1)
          selectedRange$y <- c(0, yMax)
        }
      }
    )
    
    # Chart Response Time
    #
    output$rspTimeChart<- renderPlot({ 
      
      rspData <- 
        rbind (data.frame(util= rho, rsp = W(gsQueue()), qtype = 'Grocery Store'), 
               data.frame(util= rho, rsp = W(btQueue()), qtype = 'Bank Teller'), 
               data.frame(util= rho, rsp = W(ssQueue()), qtype = 'Super Server') 
        )
      
      g <- 
        ggplot(
          data=rspData,
          aes(y = rsp, 
              x = util, 
              colour = qtype)) +  
        ggtitle(expression(paste('Response time ',italic('hockey sticks'),' as load increases'))) +
        labs(y      = 'Relative Response Time', 
             x      = 'System Utilization',
             colour = '') +
        #geom_point() + 
        geom_line(size = 0.75) +
        coord_cartesian(xlim = selectedRange$x, 
                        ylim = selectedRange$y) + 
        # scale_y_continuous(labels = yLabels, breaks = yBreaks) +
        scale_y_continuous(labels = formatYLabel) +
        scale_x_continuous(labels = percent, breaks = xBreaks) +
        theme(plot.title      = element_text(size = 16, hjust = 0), 
              axis.title.x    = element_text(size = 12, colour = 'grey50'),
              axis.text.x     = element_text(size = 12, colour = 'grey50'),
              axis.title.y    = element_text(size = 12, colour = 'grey50'),
              axis.text.y     = element_text(size = 12, colour = 'grey50'),
              legend.position   = 'top',
              legend.title      = element_blank(),
              legend.text       = element_text(size = 14),
              legend.key        = element_rect(fill = 'transparent'),
              legend.background = element_rect(fill = 'transparent')
        )
      g
    })
    
    # Chart Response Time Componenets 
    #
    output$waitTimeChart<- renderPlot({ 
      
      df <-  rbind (
          data.frame(util = rho, rspcat = 'Wait Time', time = Wq(gsQueue()), qtype = 'Grocery Store'), 
          data.frame(util = rho, rspcat = 'Wait Time', time = Wq(btQueue()), qtype = 'Bank Teller'), 
          data.frame(util = rho, rspcat = 'Wait Time', time = Wq(ssQueue()), qtype = 'Super Server'),
          
          data.frame(util = rho, rspcat = 'Service Time',  time = rep(1,     nPoints), qtype = 'Grocery Store'),
          data.frame(util = rho, rspcat = 'Service Time',  time = rep(1,     nPoints), qtype = 'Bank Teller'), 
          data.frame(util = rho, rspcat = 'Service Time',  time = rep(1/N(), nPoints), qtype = 'Super Server')
        )
      
      g <- 
        ggplot(
          data=df,
          aes(y = time, 
              x = util,
              colour = rspcat
              )) +  
        facet_wrap(~ qtype, ncol = 1) +
        ggtitle(paste('Wait time dominates as load increases\nAt wait = service, response has doubled')) +
        labs(y      = 'Relative Response Time', 
             x      = 'System Utilization',
             colour = '') +
        geom_line(size = 0.75) +
        coord_cartesian(xlim = selectedRange$x, 
                        ylim = selectedRange$y) + 
        # scale_y_continuous(labels = yLabels, breaks = yBreaks) +
        scale_y_continuous(labels = formatYLabel) +
        scale_x_continuous(labels = percent, breaks = xBreaks) +
        guides(fill = guide_legend(reverse = TRUE)) +
        theme(plot.title      = element_text(size = 16, hjust = 0), 
              axis.title.x    = element_text(size = 12, colour = 'grey50'),
              axis.text.x     = element_text(size = 12, colour = 'grey50'),
              axis.title.y    = element_text(size = 12, colour = 'grey50'),
              axis.text.y     = element_text(size = 12, colour = 'grey50'),
              legend.position   = 'top',
              legend.title      = element_blank(), 
              legend.text       = element_text(size = 12, colour = 'grey50'),
              legend.background = element_rect(fill = 'transparent'),
              legend.key        = element_rect(fill = 'transparent'),
              strip.text = element_text(size = 14)
        )
      g
    })
    
  } 
) 
    