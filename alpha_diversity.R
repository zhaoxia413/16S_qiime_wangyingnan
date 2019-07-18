setwd("F:\\16S _results20190711\\diversity\\AlphaDiversity")
library(vegan)
library(phyloseq)
library(ggstatsplot)
library(tidyverse)
library(reshape2)
library(ggthemes)
library(hrbrthemes)
library(RColorBrewer)
alphaindex<-read.csv("alpha_diversity.csv",header = T)
str(alphaindex)
a_plotdata<- melt(alphaindex,id.vars = c("Samples","Group"), value.name = "Values",variable.name =  "Index")
head(a_plotdata)
p<-ggbetweenstats(subset(a_plotdata,Index == "shannon"),
                  x=Group,y=Values,
                  type = "np",
                  pairwise.display = "s",
                  pairwise.comparisons = TRUE,
                  pairwise.annotation = "p",
                  p.adjust.method = "fdr",
                  title = "shannon",
                  ggstatsplot.layer = FALSE,
                  messages = FALSE)
p+theme_bw()

p1<-ggbetweenstats(subset(a_plotdata,Index == "evenness"),
                   x=Group,y=Values,
                   type = "np",
                   pairwise.display = "s",
                   pairwise.comparisons = TRUE,
                   pairwise.annotation = "p",
                   p.adjust.method = "fdr",
                   title = "evenness",
                   ggstatsplot.layer = FALSE,
                   messages = FALSE)
p1+theme_bw()
p2<-ggbetweenstats(subset(a_plotdata,Index == "faith_pd"),x=Group,y=Values,
                   type = "np",
                   pairwise.display = "s",
                   pairwise.comparisons = TRUE,
                   pairwise.annotation = "p",
                   p.adjust.method = "fdr",
                   title = "faith_pd",
                   ggstatsplot.layer = FALSE,
                   messages = FALSE)
p2+theme_bw()

p4<-ggbetweenstats(subset(a_plotdata,Index == "FB_ratio"),x=Group,y=Values,
                   type = "np",
                   pairwise.display = "s",
                   pairwise.comparisons = TRUE,
                   pairwise.annotation = "p",
                   p.adjust.method = "fdr",
                   title = "FB_ratio",
                   ggstatsplot.layer = FALSE,
                   messages = FALSE)
p4+theme_bw()

p3<-ggplot(a_plotdata,aes(Group,Values,fill = Group))+
  geom_violin(width =1)+
  geom_boxplot(width =0.1,color = "black",alpha= 1,fill = "white")+
  scale_fill_aaas()+
  facet_wrap(~Index,scales = "free")+
  theme_clean()+
  theme(axis.title = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.text = element_text(size = 12),
        legend.text = element_text(size = 12),
        strip.text = element_text(colour = "Black", size=14),
        strip.background=element_rect(fill="white", colour = "white", size=12, linetype = 1))
p3

