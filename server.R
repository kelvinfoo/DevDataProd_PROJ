library(shiny)
library(caret)
require(randomForest)
require(gbm)
require(survival)
require(splines)
require(parallel)
require(plyr)
require(e1071)

data(quakes)
quakes$impact <- sapply(quakes$mag, function(x) if(x<=4.9) c("Light") else if(x<=5.9) c("Moderate") else c("Strong"))
set.seed(7)
shrink <- createDataPartition(y=as.factor(quakes$impact), p=0.3, list=F)
quakes <- quakes[shrink,]

shinyServer(function(input, output) {

    setModel <- reactive({
        set.seed(7)
        inTrain <- createDataPartition(y=as.factor(quakes$impact), p=input$trData/100, list=F)
        training <- quakes[inTrain,]
        testing <- quakes[-inTrain,]
        set.seed(7)
        if(input$model=="gbm")
            modelFit <- train(as.factor(impact)~., data=training, preProcess=c("pca"), trControl=trainControl(method="cv", number=as.numeric(input$cv)), method="gbm", verbose=F)
        else if(input$model=="rf")
            modelFit <- train(as.factor(impact)~., data=training, preProcess=c("pca"), trControl=trainControl(method="cv", number=as.numeric(input$cv)), method="rf")            
        else
            modelFit <- train(as.factor(impact)~., data=training, preProcess=c("pca"), trControl=trainControl(method="cv", number=as.numeric(input$cv)), method="knn")
    })
    
    ## Only for ShinyApps: Function to return testing partition, called from output$gplot
    setTesting <- reactive({
        set.seed(7)
        inTrain <- createDataPartition(y=as.factor(quakes$impact), p=input$trData/100, list=F)
        testing <- quakes[-inTrain,]
    })

    output$mod <- renderPrint({
        modelFit <- setModel()
        modelFit
    })

    output$dplot <- renderPlot({
        modelFit <- setModel()
        plot(modelFit)
    })
    
    output$gplot <- renderPlot({
        modelFit <- setModel()
        
        ## Re-creating the partition as ShinyApps is unable to scope the testing object in setModel()
        ## Below line can be removed if running from Rstudio
        testing <- setTesting()
        
        ## Predict using the model against testing dataset
        pred <- predict(modelFit, testing)
        
        ## Create a data frame from the confusion matrix table
        ctable <- as.data.frame(confusionMatrix(pred, testing$impact)$table)
        ctable[1:2] <- apply(ctable[1:2], 2, as.character)
        
        ## Get the sum of occurence for each classification to calculate the percentage accuracy
        aggr <- aggregate(Freq~Reference, data=ctable, sum)
        colnames(aggr) = c("Reference", "Sum")
        ctable <- merge(ctable, aggr)
        ctable$Percent <- (ctable$Freq/ctable$Sum)*100
        
        ## Plot the confusion matrix table
        tile <- ggplot() + geom_tile(aes(x=Reference, y=Prediction, fill=Percent), data=ctable, color="black", size=0.1) + labs(x="Actual", y="Predicted")
        tile <- tile + geom_text(aes(x=Reference, y=Prediction, label=sprintf("%.1f", Percent)), data=ctable, size=7, color="black") + scale_fill_gradient(low="grey", high="red")
        tile <- tile + geom_tile(aes(x=Reference, y=Prediction), data=subset(ctable, as.character(Reference)==as.character(Prediction)), color="black", size=0.5, fill="black", alpha=0)
        tile        
    })
})