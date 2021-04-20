useSweetAlert()
# UIHeader ----
header <- dashboardHeader(
    title = "Práctica Final R Shiny",
    dropdownMenu(type = "messages",
                 messageItem(
                 from = "Alejandro Gallego",
                 message = "Bienvenido!"),
                 messageItem(
                     from = 'Nacho Lorenzo', 
                     message = "Gracias por estar aqui!")
    ))

# UISidebar ----
sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Introducción", tabName = "intro", icon = icon("dashboard")),
        menuItem("Producto Interior Bruto", icon = icon("chart-bar"), 
                 tabName = "mapa"),
        menuItem('Predicción', tabName = 'grafico',
                 badgeLabel = "new", badgeColor = "green",
                 icon = icon('calendar'))
    )
)
# UIBody ----
body <- dashboardBody(
    tabItems(
        # Tab de introduccion ----
        tabItem(tabName = "intro",
                h2("Esta es la introducción a la práctica final de Shiny de 
                Data Visualization.
                   En la primera pestaña podrás visualizar el Producto Interior 
                   Bruto de las diferentes provincias y comunidades 
                   autónomas españolas. En la segunda, podrás predecir y ver la 
                   tendencia del PIB según el lugar, el tiempo y el nivel
                   de confianza deseado.")
        ),
        # Tab de mapa ----
        tabItem(tabName = "mapa",
                fluidRow(
                        box(title = 'Diagrama de barras con PIB por provincias',
                           id = 'tabset1',
                           width = 6,
                           height = '675px',
                           tabPanel(title = tagList(icon('table'), 
                                                    'Gráfico Interactivo'),
                                    value = 'mapa1',
                                    textOutput('text1'),
                                    uiOutput('ui_prov'),
                                    shinycssloaders::withSpinner(type = 6,
                                        plotlyOutput('plotly_prov',
                                                     height = '500px')
                                        )
                                    )
                           ),
                        box(title = 'Mapa de España',
                           id = 'tabset2',
                           width = 6,
                           height = '675px',
                           tabPanel(title = tagList(icon('map-marker'),
                                                    'Mapa Interactivo'),
                                    value = 'mapa1',
                                    shinycssloaders::withSpinner(type = 6,
                                        highchartOutput('hc_map',
                                                        height = '540px')
                                        )
                                    )
                           )
                    )
                ),
        
        # Tab de predicciones ----
        tabItem(tabName = "grafico",
                fluidRow(
                    uiOutput('selectores_pre')
                ),
                fluidRow(
                    tabBox(id = 'tabset3',
                           width = 12,
                           tabPanel(title=tagList(icon('chart-line'),
                                                  'Predicciones'),
                                    value = 'mapa2',
                                    prettySwitch(
                                        inputId = "log",
                                        label = "Pulsa para usar el logaritmo"),
                                    shinycssloaders::withSpinner(type = 6,
                                        highchartOutput('pre_prov',
                                                        height = '530px')
                                        )
                                    ),
                           tabPanel(
                               title = tagList(icon('table'),
                                               'Tabla de Predicciones'), 
                               value = 'tabla2',
                               shinycssloaders::withSpinner(type = 6,
                                   tableOutput('table_pre_prov')
                                   ),
                               downloadBttn('downloadData', 
                                            style = 'material-flat',
                                            color = 'primary')
                               )
                           )
                    )
                )
        )
    )

shinyUI(dashboardPage(
    header,
    sidebar,
    body
    ))
