library(shiny)
library(nycflights13)
library(dplyr)
library(ggplot2)

viz_monthly <- function(df, y_var, threshhold = NULL) {

  ggplot(df) +
    aes(
      x = .data[["day"]],
      y = .data[[y_var]]
    ) +
    geom_line() +
    geom_hline(yintercept = threshhold, color = "red", linetype = 2) +
    scale_x_continuous(breaks = seq(1, 29, by = 7)) +
    theme_minimal()
}

datin <- nycflights13::flights %>%
  filter(carrier %in% c('AA', 'DL', 'UA')) %>%
  mutate(ind_arr_delay = (arr_delay > 5)) %>%
  group_by(year, month, day, carrier) %>%
  summarize(
    n = n(),
    across(ends_with("delay"), mean, na.rm = TRUE)
  ) %>%
  ungroup()

# text module ----
text_ui <- function(id) {

  fluidRow(
    textOutput(NS(id, "text"))
  )

}

text_server <- function(id, df, vbl, threshhold, carrier) {

  moduleServer(id, function(input, output, session) {

    n <- reactive({sum(df()[[vbl]] > threshhold())})
    output$text <- renderText({
      paste("In this month",
            vbl,
            "exceeded the average daily threshhold of",
            threshhold(),
            "a total of",
            n(),
            "days for carrier",
            carrier()
            )
    })

  })

}

# plot module ----
plot_ui <- function(id) {

  fluidRow(
    column(12, plotOutput(NS(id, "plot"))),
  )

}

plot_server <- function(id, df, vbl, threshhold = NULL) {

  moduleServer(id, function(input, output, session) {

    plot <- reactive({viz_monthly(df(), vbl, threshhold())})
    output$plot <- renderPlot({plot()})

  })
}

# metric module ----
metric_ui <- function(id) {

  fluidRow(
    text_ui(NS(id, "metric")),
    plot_ui(NS(id, "metric"))
  )

}

metric_server <- function(id, df, vbl, threshhold, carrier) {

  moduleServer(id, function(input, output, session) {

    text_server("metric", df, vbl, threshhold, carrier)
    plot_server("metric", df, vbl, threshhold)

  })

}

# full application ----
ui <- fluidPage(

  titlePanel("Flight Delay Report"),

  sidebarLayout(
    sidebarPanel = sidebarPanel(
      selectInput("month", "Month",
                  choices = setNames(1:12, month.abb),
                  selected = 1
      ),
      selectInput("crr", "Carrier",
                  choices = unique(datin$carrier)
      ),
      numericInput('thr', 'Threshold',
                   min = 1, max = 20, step = 1, value = 11)
    ),
    mainPanel = mainPanel(
      h2(textOutput("title")),
      h3("Average Departure Delay"),
      metric_ui("dep_delay"),
      h3("Average Arrival Delay"),
      metric_ui("arr_delay"),
      h3("Proportion Flights with >5 Min Arrival Delay"),
      metric_ui("ind_arr_delay")
    )
  )
)
server <- function(input, output, session) {

  output$title <- renderText({paste(month.abb[as.integer(input$month)], "Report")})
  df_month <- reactive({filter(datin, month == input$month & carrier == input$crr)})
  thresh <- reactive({input$thr})
  carrier <- reactive(input$crr)
  metric_server("dep_delay", df_month, vbl = "dep_delay", threshhold = thresh, carrier = carrier)
  metric_server("arr_delay", df_month, vbl = "arr_delay", threshhold = thresh, carrier = carrier)
  metric_server("ind_arr_delay", df_month, vbl = "ind_arr_delay", threshhold = thresh, carrier = carrier)

}
shinyApp(ui, server)
