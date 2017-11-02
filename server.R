
function(input, output) {
  
  output$network <- renderPlot({
    # input$file1 will be NULL initially. After the user selects and uploads a file, 
    # it will be a data frame with 'name', 'size', 'type', and 'datapath' columns. 
    # The 'datapath' column will contain the local filenames where the data can be found.
    
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    parsed <- readr::read_csv(inFile$datapath)
    
    library(shiny)
    output$text <- renderText({
      paste("The number of document is: ", nrow(parsed), sep="")
    })
    
    #sparsed$parsedContent <- gsub(" ", "  ", parsed$parsedContent)
    
    library(tm)
    corpus <- VCorpus(VectorSource(parsed$parsedContent))
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, stripWhitespace)
    corpus <- tm_map(corpus, tolower)
    
    library(stringi)
    if(nchar(stri_split_fixed(input$stopTerm, ",")) > 0) {
      disuse.term <- unlist(stri_split_fixed(input$stopTerm, ","))
      corpus <- tm_map(corpus, removeWords, disuse.term)
    }
    
    corpus <- tm_map(corpus, PlainTextDocument)
    
    # Document Term Matrix 생성 : Tf-Idf값을 가중치로 이용
    dtm <- DocumentTermMatrix(corpus, 
                              control=list(removeNumbers=FALSE, 
                                           wordLengths=c(2,Inf), 
                                           weighting=function(x) weightTfIdf(x, normalize=T)))
    
    # 단어 양옆 스페이스 제거 및 2음절 이상 단어만 남기기
    colnames(dtm) <- trimws(colnames(dtm))
    dtm <- dtm[, nchar(colnames(dtm))>=2]
    dtm <- removeSparseTerms(dtm, as.numeric(input$sparse))
    
    # 매트릭스 크기 조절하기
    corTerms <- cor(as.matrix(dtm))
    corTerms[corTerms < input$corLimit] <- 0
    
    # 네트워크 객체 생성
    library(network)
    netTerms <- network(corTerms, directed=FALSE)
    btnTerms <- sna::betweenness(netTerms)
    #netTerms %v% "mode" <- ifelse(btnTerms>=quantile(btnTerms,0.9), "Top10%", "Rest90%")
    #nodeColors <- c("Top10%"="gold", "Rest90%"="white")
    set.edge.value(netTerms, "edgeSize", corTerms*2)
    
    library(GGally)
    ggnet2(netTerms, 
           layout.par=list(cell.jitter=0.001),
           label=TRUE, 
           label.size=8, 
           node.color="white", 
           #color="mode",
           #palette=nodeColors, 
           #size=degree(netTerms), 
           edge.size="edgeSize",
           size.min=2,
           legend.position="None",
           family="NanumGothic")
  })
}