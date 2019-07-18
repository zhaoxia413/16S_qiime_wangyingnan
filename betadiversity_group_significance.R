library(tidyverse)
library(RColorBrewer)
library(ggsci)
library(data.table)
library(ggthemes)
setwd("F:\\16S _results20190711\\diversity\\BetaDiversity")
data<-fread("betadiversity.csv",header = T)
head(data)
p<- ggplot(subset(data,Compaire = "Second"),aes(Group1,Distance,fill= Group1))+
  geom_boxplot()+
  scale_fill_aaas()+
  facet_wrap(~Method,scales = "free")+
  theme_clean()+
  theme(axis.title = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.text = element_text(size = 12),
        legend.text = element_text(size = 12),
        strip.text = element_text(colour = "Black", size=14),
        strip.background=element_rect(fill="white", colour = "white", size=12, linetype = 1))
  
p

