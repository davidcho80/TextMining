# Text Mining R Code

크롤링부터 토픽 클러스터링(LDA)까지 코멘트가 되어있는 R 코드 입니다.

## Getting Started

시작하는 방법

1. 아래 파일들을 순서대로 읽어보시면 됩니다.

### Files

```text
.
├── createNamJson_v2.R
├── Step1 Text data preparation.R
├── Step2 Explorative Data Analysis.R
├── Step3 Create xlsx file and Parsing.R
├── Step4 Check words frequency.R
├── Step5 Create corpus and DTM.R
├── Step6 Extract related keywords.R
├── Step7 WordCloud and Treemap.R
├── Step8 Topic clustering (LDA).R
└── stopwords.txt
```
### Prerequisites

아래와 같은 패키지가 필요로 합니다.

```R
library(readxl)
library(ggplot2)
library(slam)
library(tm)
library(xlsx)
library(NLP4kec)
library(dplyr)
library(RColorBrewer)
```

### Installing

파일을 실행시키면서 만나게 될때마다 설치하시면 됩니다 ㅜㅜ

## Contributing

네트워크맵도 추가해야 하고 지금 올린 코드 중에도 보완해야 할 부분이 많지만, 혹시 보시다가 오류를 발견하시면 제게 피드백 부탁 드립니다.

## Authors

- **Kevin Seongho Na**
- [컨트리뷰터 리스트](https://github.com/DrKevin22/TextMining/graphs/contributors)

## License

 MIT License - see the [LICENSE.md](LICENSE.md) file for details
