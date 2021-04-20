
shinyServer(function(session, input, output) {
  
  # PREDICCIONES ----
  
  # Info ----
  
  observeEvent(input$info, {
    sendSweetAlert(
      session = session,
      title = "Información",
      text = "Una vez SELECCIONES UNA PROVINCIA, el NIVEL DE CONFIANZA \
      dictamina el rango de error en la predicción y el HORIZONTE  \
      DE PREDICCIÓN el número de años a predecir.",
      type = "info"
    )
  })
  
  # Reactivos ----
  
  reactivo_pred_tabl <- reactive({
    datos_prov
  })
  
  # Render UI tab predicciones ----
  
  output$selectores_pre <- renderUI({

    tagList(
      column(width = 1,
             actionBttn('info', 
                        icon = icon('info-circle'),
                        style = "material-circle", 
                        color = "primary")
             ),
      box(align = 'center',
          width = 3,
          height = '100px',
          selectInput('selector_prov', 'Selecciona provincia',
                      choices = rownames(reactivo_pred_tabl())
                      )
      ),
      box(align = 'center',
          width = 3,
          height = '100px',
          sliderTextInput(
            inputId = "level",
            label = "Nivel de confianza",
            choices = 50:100,
            grid = TRUE
          )
      ),
      box(align = 'center',
          width = 3,
          height = '100px',
          numericInput(inputId = "anios",
                       label =  "Horizonte de predicción",
                       value = 5,
                       min = 1,
                       step = 1)
          
      ),
      column(
          width = 2,
          actionBttn('update', 'Actualizar predicción',
                     style = "material-flat",
                     icon = icon("caret-square-right"),
                     color = "primary",
                     size = "md",
                     block = T)
          )
      )
  })
  
  # Reactivo para aislar predicciones ----
  
  reactivo_ts <- reactive({
    
    input$update

    prov <- isolate(input$selector_prov)
    level <- isolate(input$level)
    anios <- isolate(input$anios)
    
    ts_prov <- ts(t(as.matrix(reactivo_pred_tabl()[prov,])),
                     start = 2000,
                     end = 2019,
                     frequency = 1)
    
    pre_prov <- forecast(auto.arima(ts_prov), 
                         level = level,
                         h = anios)
    pre_prov
  })
  
  # Reactivo para aislar predicciones y uso del log ----
  
  reactivo_ts_log <- reactive({
    
    input$update
    
    prov <- isolate(input$selector_prov)
    level <- isolate(input$level)
    anios <- isolate(input$anios)
    
    ts_prov <- log(ts(t(as.matrix(reactivo_pred_tabl()[prov,])),
                  start = 2000,
                  end = 2019,
                  frequency = 1)
                  )
    
    pre_prov <- forecast(auto.arima(ts_prov), level = level,
                         h = anios)
    pre_prov
  })
  
  # Grafico de predicciones ----
  
  output$pre_prov <- renderHighchart({
    
    if (input$log){
      hchart(reactivo_ts_log()) %>% hc_add_theme(hc_theme_sandsignika())
    } else {
      hchart(reactivo_ts()) %>% hc_add_theme(hc_theme_sandsignika())
    }
    
  })
  
  # Tabla de predicciones ----
  
  output$table_pre_prov <- function(){
    
    input$update
    
    level <- isolate(input$level)
    
    if(input$log){
      
      kable(reactivo_ts_log(), 
            col.names = c("Predicción", 
                          paste('Limite inferior', level,'%'), 
                          paste('Limite superior', level,'%')), 
            align = "c") %>%
        kable_styling(bootstrap_options = "striped", 
                      full_width = F, 
                      position = "center")
    } else {
      
      kable(reactivo_ts(), 
            col.names = c("Predicción", 
                          paste('Limite inferior', level,'%'), 
                          paste('Limite superior', level,'%')), 
            align = "c") %>%
        kable_styling(bootstrap_options = "striped", 
                      full_width = F, 
                      position = "center")
    }
    
  }
  
  # Download tabla predicciones ----
  
  output$downloadData <- downloadHandler(
    
    filename = function() { 
      paste("Predicción", 
            '_', input$selector_prov, '_',
            Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(reactivo_ts(), file)
    })
  
  
  # EL MAPA Y PLOTLY ----
  
  # Text ----
  
  output$text1 <- renderText({
    'Pulsa aquí'
  })
  
  output$text2 <- renderText({
    '*Para volver a visualizar el top de nuevo, debes deseleccionar \
    todas las provincias.'
  })
  
  # Reactivos ----
  
  reactivo_hpmap_ggplot <- reactive({
    data_hcmap_ggplot
  })
  
  # Render UI tab plotly y mapa ----
  
  output$ui_prov <- renderUI({
    
    tagList(
      dropdown(
        tags$h3("Personalización"),
        numericInput("top",
                     label = 'Elige un top de provincias para visualizar',
                     value = 10,
                     step = 1),
        pickerInput(inputId = "sel_prov",
                    label = "Selecciona provincias por nombre",
                    choices = reactivo_hpmap_ggplot()$name,
                    multiple = TRUE,
                    options = list(`style` = "btn-info")),
        textOutput('text2'),
        style = "unite", 
        icon = icon("gear"),
        status = "primary", 
        width = "300px",
        animate = animateOptions(
          enter = animations$fading_entrances$fadeInLeftBig,
          exit = animations$fading_exits$fadeOutRightBig
          )
        )
      )

  })
  
  # Plotly con PIB por provincia ----
  
  # Reactive para filtar el plotly

  reactivo_plotly <- reactive({
      
      if (length(input$sel_prov) >=1){
        
        goodprov <- input$sel_prov
        data <- reactivo_hpmap_ggplot() %>%  filter(name %in% goodprov)
        
      } else {
        
        data <- reactivo_hpmap_ggplot()
        
      }
      
      g = data[order(data$pib, decreasing = T),] %>%
        top_n(n = input$top, wt = pib) %>% 
        mutate(name = fct_reorder(name, pib)) %>%
        ggplot( aes(x=name, y=pib)) +
        geom_bar(stat="identity", fill="#f68060", alpha=.6, width=.4) +
        coord_flip() +
        xlab("") +
        ylab('Producto Interior Bruto') +
        theme_bw()
      g

  })
  
  output$plotly_prov <- renderPlotly({

    ggplotly(reactivo_plotly())

  })
  
  # Mapa de españa ----
  
  output$hc_map <- renderHighchart({
    
    hcmap("countries/es/es-all", data = reactivo_hpmap_ggplot(), value = "pib",
          joinBy = c("hc-a2", "code"), name = "Producto Interior Bruto",
          dataLabels = list(enabled = TRUE, format = '{point.name}'),
          borderColor = "#98ad0e", borderWidth = 0.1,
          tooltip = list(valueDecimals = 0, valueSuffix = " €"))

  })
  
 
  
})
