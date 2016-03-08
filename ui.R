
library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel(h2('Response Time of Three Simple Queueing Systems')),  
  
  sidebarPanel(
    
    h4('Overview'),
    
    helpText("Consider three different queueing systems:"),
    helpText('- ', strong('Grocery Store'), ' has a separate queue for each of N servers.'),
    helpText('- ', strong('Bank Teller'),   ' has a single queue feeding all N servers.'),
    helpText('- ', strong('Super Server'),  ' has a single line to a single server that is',
             'N times as fast as the other two systems.'),
    
    helpText('The', strong('Overview'),'tab shows a picture of the queues for N=6.'),
    
    helpText('All three systems have identical throughput capacity, that is, they can service',
             'the same number of transactions per second.'),
    
    helpText('And when there is a single server (i.e., N=1), the systems have the same',
             'response time characteristics.'),
    
    helpText('But as the number of servers increases (N>1), their response time', 
             'characteristics are distinctly different.'),
    
    h4('Explore Response Times'),
    
    helpText('Click on the', strong('Response Times Charts'), 'tab to see interactive',
             'charts showing the response time for the three queue systems',
             'across all load levels'), 
    
    helpText('Use the slider to change the number of servers and explore the differences',
             'between the three systems.'),
             
    sliderInput('nServers', label = 'Number of Servers (N):',
                min = 1, max = 16, value = 1),
    
    helpText(strong('Zoom in'), ' by selecting a region in the top chart then ',
             'double-clicking within the selection. All four charts will zoom', 
             'to the selected range'),
    
    helpText(strong('Reset'),   ' to the default zoom by double clicking in the top chart.'), 
    
    helpText('An interesting zoom level is 0-2x relative response time (y-axis)',
             'for all utilizations ')
  ),
  
  mainPanel(
    
    tabsetPanel(
      tabPanel('Overview', 
               img(src = '3qnetworks.png', height = '343px', width = '810px')
      ),
      tabPanel("Response Time Charts", 
               plotOutput('rspTimeChart', height = 350, width = 400, 
                          dblclick = 'rspTimeChart.dblClick',     
                          brush = brushOpts(
                            id = 'rspTimeChart.brush',
                            resetOnNew = TRUE
                          )  
               ),
               plotOutput('waitTimeChart', height = 900, width = 400)
      ),
      tabPanel("References", 
               helpText('Thanks to the following resources:'),   
               helpText('-', 
                        a(href='http://www.cmg.org/publications/conference-proceedings/conference-proceedings2015/', 
                          'Developing Our Intuition About Queuing Network Models'
                        ),
                        ', An analysis of the three queuing systems presented here', 
                        'and the inspiration for our shiny application.'
               ),
               
               helpText('-',
                        a(href='http://cran.r-project.org/web/packages/queueing/queueing.pdf', 
                          'queueing: Analysis of Queueing Networks and Models'),
                        ', An R package by Pedro Canadilla for solving queueing networks.', 
                        'We used it in our shiny application.'
               )
      )
    ) 
  ) 
)) 
