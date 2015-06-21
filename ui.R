# Define UI for Quake Impact prediction application
shinyUI(pageWithSidebar(
    
    # Application title
    headerPanel("Quake Impact Predictor"),
    
    # Sidebar with controls to provide a caption, select a dataset, and 
    # specify the number of observations to view. Note that changes made
    # to the caption in the textInput control are updated in the output
    # area immediately as you type
    sidebarPanel(
    #    textInput("caption", "Caption:", "Data Summary"),
        
        selectInput("model", "Choose a prediction model:", 
                    choices = c("gbm", "rf", "knn")),
        
        sliderInput("trData", "Adjust training dataset size (in %)",
                    min = 50, max = 90, step = 5, value = 70),
        
        radioButtons("cv", "Select number of Cross Validations to be performed:",
                     c("3" = 3, "5" = 5, "10" = 10), inline=TRUE)
    #    numericInput("obs", "Number of observations to view:", 10)
    ),

    
    # Show the caption, a summary of the dataset and an HTML table with
    # the requested number of observations
    mainPanel(
        tabsetPanel(
            tabPanel("Output",
                verbatimTextOutput("mod"), 
                plotOutput("dplot"),
                plotOutput("gplot")
            ),
            tabPanel("Documentation",
                h1("Quake Impact Predictor"),
                h3("1. Introduction"),
                h5("The Quake Impact Predictor application uses the 'quakes' dataset and attempts predict the scale of a quake using different prediction models and parameters.
                    The objective of this application is to display a simple and quick output of 3 different prediction models when used with different basic parameters."),
                h3("2. Prediction Models"),
                h5("The 3 available prediction models for testing are:"),
                h5("a. gbm (gradient boosting model)"),
                h5("b. rf (random forest)"),
                h5("c. knn (k nearest neighbor)"),
                h5("These models can be easily selected using a drop-down selection textbox."),
                h3("3. Basic Parameters"),
                h5("The basic parameters that can be adjusted are:"),
                br(),
                h5("a. Training Data Size (in %) (between 50% to 90%, larger size may yield better accuracy but longer processing time)"),
                br(),
                h5("b. Cross-validation (number cross-validations to be performed, larger size may yield better accuracy but longer processing time)"),
                br(),
                h3("4. Exploratory Data Analysis"),
                h5("The dataset used in this application comes from the default 'quakes' dataset. The dataset give locations of 1000 seismic events of magnitude greater than 4.0. The events occurred near Fiji since 1964."),
                h5("The variables in this dataset are:"),
                h5("[,1] lat numeric Latitude of event"),
                h5("[,2] long numeric Longitude"),
                h5("[,3] depth numeric Depth (km)"),
                h5("[,4] mag numeric Richter Magnitude"),
                h5("[,5] stations numeric Number of stations reporting"),
                h5("The magnitude readings are categorized according to standard seismic scales. See this link for reference. The categorized readings are stored in a new 'impact' column."),
                h5("In order to reduce the processing time of the prediction models, only 30% of the 1000 observations will be used. Accuracy is dropped in favour of performance and objective of the application."),
                h3("5. Outputs"),
                h5("The application produces 3 outputs pertaining to the selected prediction model and parameters selected."),
                h4("5.1 Prediction Model Information"),
                h5("The first information displayed is the details of the selected prediction model. Useful data such as accuracy on in-sample error, kappa, etc, can be found."),
                h4("5.2 Plot of Prediction Model"),
                h5("This graph shows the different number of iterations used by the prediction model and compare the most accurate iteration that will be selected."),
                h4("5.3 Confusion Matrix on Testing data partition"),
                h5("The matrix plot shows the percentage of actual vs predicted results when the prediction model is applied onto the testing data partition.")
            )
        )
    )
))