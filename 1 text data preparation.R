

#--------------------------------------------------------------------------
# 크롤러로 수집한 데이터 정리
#--------------------------------------------------------------------------

# 작업경로 설정
setwd("~/Jupyter/TextMining/Data")

# 텍스트 데이터 목록 확인
(fileList <- list.files(path=getwd()))

# 작업일자 지정
(today <- gsub("-", "", Sys.Date()))

# 글의 종류와 날짜 지정
type <- "Blog"
query <- "지름신"
(docName <- paste(type, query, sep = "_"))

# 위에서 지정한 파일만 가지고 오기
fileList <-
  fileList[grepl(paste(c("20170731", "20170801"), collapse = "|"), fileList)]
fileList
grep("뱅크", fileList, value = T)

# 엑셀파일 불러오기
text <- data.frame()
for (i in 1:length(fileList)) {
  blog <- readxl::read_excel(paste(getwd(), fileList[i], sep = "/"))
  blog <- as.data.frame(blog)
  text <- rbind(text, blog)
}

# 블로그 요약과 본문 합치기 (블로그)
text$content <- paste(text$summary, text$fulltext)
text$content <- gsub("NA", "", text$content)

# 컬럼 순서 변경
text <-
  text[, c("bank",
           "title",
           "postdate",
           "link",
           "content",
           "summary",
           "fulltext")]

# 텍스트마이닝 데이터 만들기
# 20170101 이후 포스팅만
tmdf <- text[text$postdate >= "20170101", ]
tmdf$id <- seq(1, nrow(tmdf))

# 불필요한 컬럼 삭제
tmdf <- tmdf[, c("id", "bank", "postdate", "content")]

# 중복 제거
tmdf <- dplyr::distinct(tmdf, content, .keep_all = T)