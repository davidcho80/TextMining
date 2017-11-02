
#--------------------------------------------------------------------------
# 연관 키워드 네트워크 맵 그리기
#--------------------------------------------------------------------------

# Network Map용 데이터 확인 (단어*단어 상관계수 매트릭스 생성)
corTermsW[1:10,1:10]

# edge 개수 조절하기
# 상관계수가 0보다 큰 것만 사용하는데, 
# 모두 포함시키면 꽤 크므로 0.1 미만은 0으로 치환!
corTermsW[corTermsW<0.1] <- 0
class(corTermsW)

# Network Map을 그리기 위한 객체 만들기 
# 화살표가 있는 네트워크를 유향, 없는 것을 무향이라고 함
# 텍스트 마이닝에서는 '방향'이 큰의미 없으므로 '무향 네트워크' 선택 (directed=F)
# node(vertices)와 edge(total edges) 확인
library(network)
netTermsW <- network(corTermsW, directed=F)
class(netTermsW)
netTermsW

# 각 edge의 중개 중심성(betweenness centrality) 계산
library(sna)
btnTermsW <- betweenness(netTermsW)
btnTermsW

# library(igraph)
# graph <- graph.data.frame(corTerms, directed=F)
# graph
# btwn <- betweenness(graph)
# class(btwn)
# btwn


# 히스토그램 그리기 
hist(btnTermsW, breaks=15)
ggplot(data=as.data.frame(btnTermsW), aes(x=btnTermsW)) + 
  geom_histogram(breaks=seq(0,60000,2000), col="black", fill="white")




#--------------------------------------------------------------------------
# Network Map 화면에 그리기
#--------------------------------------------------------------------------

# 90% 백분위수(percential) 값 확인
pcnt90 <- quantile(btnTermsW, probs=0.90)
pcnt90

# network의 betweenness값 상위 10% node에 금색, 나머지 90% node에 회색 지정 
# %v% 연산자 사용하여 network 객체에 "mode" 속성을 만들고 "Top10%"와 "Rest90%" 할당
netTermsW %v% "mode" <- ifelse(btnTermsW >= pcnt90, "Top10%", "Rest90%")
nodeColors <- c("Top10%"="gold", "Rest90%"="grey")
nodeColors

# Network edge size 값 설정하기 (단어 간 상관계수의 2배로 지정)
set.edge.value(netTermsW, "edgeSize", corTermsW*2)

# 전체 네트워크 그리기
library(GGally)
ggnet2(net=netTermsW,               # 네트워크 객체
       layout.par=list(cell.jitter=0.01),
       #na.rm=T,
       label=TRUE,                  # 노드에 레이블 출력 여부
       label.size=3,                # 레이블 폰트 크기
       color="mode",                # 노드의 색상 구분 기준
       palette=nodeColors,          # 노드의 색상
       size="degree",               # 노드의 크기를 degree cetrality 값에 따라 차등
       edge.size="edgeSize",        # 엣지의 굵기를 단어간 상관계수에 따라 차등
       size.min=20, 
       legend.position="None",
       mode="fruchtermanreingold",  # "circle","kamadakawai","fruchtermanreingold","circrand"
       family="NanumGothic")        # 폰트 할당 


#--------------------------------------------------------------------------
#--------------------------------------------------------------------------

# 상관계수 재조정
corTermsW <- cor(dtmWMat)
corTermsW[corTermsW<0.05] <- 0

# 키워드의 열만 추출
keywords
subCorTerms <- corTermsW[, keywords]

# 행에서 키워드 제외 
subCorTerms <- subCorTerms[!rownames(subCorTerms) %in% keywords,]

# 행의 합이 0 초과인 행만 남기기
subCorTerms <- subCorTerms[rowSums(subCorTerms)>0,]

# 비대칭형 네트워크인 경우, matrix.type="bipartite" 추가!!
subNetTerms <- network::network(subCorTerms, directed=F, matrix.type="bipartite")
set.edge.value(subNetTerms, "edgeSize", subCorTerms[subCorTerms>0]*2)

# 네트워크 그리기
ggnet2(net=subNetTerms,
       layout.par=list(cell.jitter=0.01),
       label=TRUE,
       label.size=4,
       edge.size="edgeSize",
       size=degree(subNetTerms),
       size.min=3,
       legend.position="None",
       mode="fruchtermanreingold",
       family="NanumGothic")


#--------------------------------------------------------------------------
#--------------------------------------------------------------------------

rm(list=ls())
gc()
getwd()

infile <- "./output/은행_Blog_Sub_Corpus_하나은행.csv"
sparse <- 0.99

# 특정 토픽 클러스터만 가지고 네트워크 맵 그리기 
plotNetmap <- function(infile, sparse=0.99) {
  parsed <- readr::read_csv(infile)
  #parsed$parsedContent
  
  # 코퍼스 생성
  library(tm)
  corpus <- VCorpus(VectorSource(parsed$parsedContent))
  
  # 특수기호 제거 
  corpus <- tm_map(corpus, removePunctuation)
  
  # 코퍼스 속성 변경 
  corpus <- tm_map(corpus, PlainTextDocument)
  
  # Document Term Matrix 생성. Tf-Idf값으로 가중치 부여
  dtm <- DocumentTermMatrix(corpus,
                            control=list(wordLengths=c(2,Inf), 
                                         weighting=function(x) weightTfIdf(x, normalize=T)))
  
  # 단어 양옆 스페이스 제거 
  colnames(dtm) <- trimws(colnames(dtm))
  
  # 2음절 이상인 단어만 남기기 
  dtm <- dtm[, nchar(colnames(dtm))>=2]
  
  # sparse 단어 삭제
  dtm <- removeSparseTerms(dtm, as.numeric(sparse))
  
  # 상관계수 매트릭스 크기 조절하기 : 0.1 이하는 0으로 치환!
  corTerms <- cor(as.matrix(dtm))
  corTerms[corTerms<=0.1] <- 0
  
  # 네트워크 객체 생성
  library(network)
  netTerms <- network(corTerms, directed=FALSE)
  
  # 중개중심성 계산 
  library(sna)
  btnTerms <- betweenness(netTerms)
  
  # 노드 색상 기준 속성 생성 및 색상 할당 
  netTerms %v% "mode" <- ifelse(btnTerms>=quantile(btnTerms, 0.9), "Top10%", "Rest90%")
  nodeColors <- c("Top10%"="gold","Rest90%"="grey")
  
  # 엣지 크기 지정 : 상관계수의 2배
  set.edge.value(netTerms, "edgeSize", corTerms*2)
  
  # 네트워크 맵 그리기
  library(GGally)
  ggnet2(net=netTerms,                # 네트워크 객체
         layout.par=list(cell.jitter=0.01),
         #na.rm=T,
         label=TRUE,                  # 노드에 레이블 출력 여부
         label.size=3,                # 레이블 폰트 크기
         color="mode",                # 노드의 색상 구분 기준
         palette=nodeColors,          # 노드의 색상
         size=degree(netTerms),       # 노드의 크기를 degree cetrality 값에 따라 차등
         edge.size="edgeSize",        # 엣지의 굵기를 단어간 상관계수에 따라 차등
         size.min=20, 
         legend.position="None",
         mode="fruchtermanreingold",  # "circle","kamadakawai","fruchtermanreingold","circrand"
         family="NanumGothic")        # 폰트 할당 
  
  
  # dtmMat <- as.matrix(dtm %>% removeSparseTerms(as.numeric(0.94)))
  # coMat <- t(dtmMat) %*% dtmMat
  # 
  # library(qgraph)
  # qgraph(input=coMat,
  #        labels=rownames(coMat),
  #        label.cex=1.6,
  #        diag=F,
  #        layout="spring",
  #        edge.color="red",
  #        vsize=log(diag(coMat)))
}

plotNetmap("./output/은행_Blog_Sub_Corpus_하나은행.csv", 0.25)


#--------------------------------------------------------------------------
#--------------------------------------------------------------------------

# Rdata로 저장
save.image(paste(docName, "_", today, ".Rdata", sep=""))
list.files(pattern="Rdata")
