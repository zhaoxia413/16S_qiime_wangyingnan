setwd("//run//media//zhaoxia//Elements//16S _results20190711")
library(tidyverse)
data<-read.csv("OTU_shared.csv",header = T)
dp<-subset(data,Category == "Phylum") %>% .[,-c(1,2)] 
dc<-subset(data,Category == "Class")%>% .[,-c(1,2)]
do<-subset(data,Category == "Order")%>% .[,-c(1,2)]
df<-subset(data,Category == "Family")%>% .[,-c(1,2)]
dg<-subset(data,Category == "Genus")%>% .[,-c(1,2)]
ds<-subset(data,Category == "Species")%>% .[,-c(1,2)]
datalist<-list(dp,dc,do,df,dg,ds)

average <- function(x){
  x/sum(x)
}
dp_abundance<- data.frame(Phylum = dp[,1],apply(dp[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
dc_abundance<- data.frame(Phylum = dc[,1],apply(dc[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
do_abundance<- data.frame(Phylum = do[,1],apply(do[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
df_abundance<- data.frame(Phylum = df[,1],apply(df[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
dg_abundance<- data.frame(Phylum = dg[,1],apply(dg[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
ds_abundance<- data.frame(Phylum = ds[,1],apply(ds[,-1],2,average)) %>% mutate(Average = (apply(.[-1],1,FUN = sum))/30)
write.csv(dp_abundance,"Phylum_abundance.csv",row.names = F)
write.csv(dc_abundance,"Class_abundance.csv",row.names = F)
write.csv(do_abundance,"Order_abundance.csv",row.names = F)
write.csv(df_abundance,"Family_abundance.csv",row.names = F)
write.csv(dg_abundance,"Genus_abundance.csv",row.names = F)
write.csv(ds_abundance,"Species_abundance.csv",row.names = F)
colnames(dp_abundance)[1]<- "Name"
colnames(dc_abundance)[1]<- "Name"
colnames(do_abundance)[1]<- "Name"
colnames(df_abundance)[1]<- "Name"
colnames(dg_abundance)[1]<- "Name"
colnames(ds_abundance)[1]<- "Name"
othervalue<-function(x){
  1-sum(x)
}
abundance<-bind_rows(dp_abundance,dc_abundance,do_abundance,df_abundance,dg_abundance,ds_abundance)
abundance1<-merge(data,abundance,by="Name")
write.csv(abundance1,"sharedAbundance.csv",row.names = F)
dp_plot<-top_n(dp_abundance,4,Average) %>% .[,-32] 
do_plot<-top_n(do_abundance,10,Average) %>% .[,-32]
dc_plot<-top_n(dc_abundance,10,Average) %>% .[,-32]
df_plot<-top_n(df_abundance,15,Average) %>% .[,-32]
dg_plot<-top_n(dg_abundance,15,Average) %>% .[,-32]
ds_plot<-top_n(ds_abundance,20,Average) %>% .[,-32]
OthersP<-dp_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersC<-dc_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersO<-do_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersF<-df_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersG<-dg_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersS<-ds_plot[,-c(1)] %>% apply(.,2,FUN =othervalue)
OthersP1 = data.frame(Taxon = "Others",t(OthersP))
OthersO1 = data.frame(Taxon = "Others",t(OthersO))
OthersC1 = data.frame(Taxon = "Others",t(OthersC))
OthersF1 = data.frame(Taxon = "Others",t(OthersF))
OthersG1 = data.frame(Taxon = "Others",t(OthersG))
OthersS1 = data.frame(Taxon = "Others",t(OthersS))
dp_plot1<- rbind(dp_plot, OthersP1)
do_plot1<- rbind(do_plot, OthersO1)
dc_plot1<- rbind(dc_plot, OthersC1)
df_plot1<- rbind(df_plot, OthersF1)
dg_plot1<- rbind(dg_plot, OthersG1)
ds_plot1<- rbind(ds_plot, OthersS1)
dp_plot2<- dp_plot1 %>% mutate(Classify = rep("Phylum",5)) 
do_plot2<-do_plot1 %>% mutate(Classify = rep("Order",11))
dc_plot2<-dc_plot1 %>% mutate(Classify = rep("Class",11))
df_plot2<-df_plot1%>% mutate(Classify = rep("Family",16))
dg_plot2<-dg_plot1 %>% mutate(Classify = rep("Genus",16))
ds_plot2<-ds_plot1%>%  mutate(Classify = rep("Secies",21))

library(reshape2)
dataplot<-bind_rows(dp_plot2,do_plot2,dc_plot2,df_plot2,dg_plot2,ds_plot2) %>% melt(.,id.vars=c("Classify","Taxon"),variable.name="Samples",value.name = "Abundance")
library(data.table)
metadata<-fread("metadata.tsv") 
meta <- data.frame(Samples = metadata$`sample-id`,Group = metadata$group)[-1,]
plotdf<-merge(dataplot,meta,by = "Samples")
write.csv(plotdf,"Taxon_abundance_merged_bar.csv",row.names = F)
plotdf<-read.csv("Taxon_abundance_merged_bar.csv",header = T)
library(tidyverse)
library(ggthemes)
library(RColorBrewer)
RColorBrewer::display.brewer.all()
newpalette<-colorRampPalette(brewer.pal(8,"Accent"))(6)
newpalette1<-colorRampPalette(brewer.pal(9,"Set1"))(10)
newpalette2<-colorRampPalette(brewer.pal(9,"Set1"))(20)
newpalette3<-colorRampPalette(brewer.pal(11,"BrBG"))(21)
plotdf$Taxon<-reorder(plotdf$Taxon,plotdf$Abundance)

order<-filter(plotdf,Taxon == "S24-7",Classify == "Family")
order$Samples<-reorder(order$Samples,order$Abundance)
plotdf$Samples=factor(plotdf$Samples,levels = levels(factor(order$Samples)))
df1<-filter(plotdf,Classify=="Phylum")
df1$Samples<-reorder(df1$Samples,df1$Abundance)
p1<-ggplot(df1,aes(Samples,Abundance,fill= Taxon))+
  geom_bar(stat = "identity", width=1, col='black')+
  theme_minimal()+scale_fill_manual(values=newpalette)+
  theme( axis.line = element_line(arrow = arrow()),axis.title.y = element_text(size = 12),
         axis.title.x = element_text(size = 12),
         legend.text = element_text(size = 12),axis.text.x = element_text(size = 12),
         axis.text.y = element_text(size = 12),axis.line.y = element_line(size = 1),
         axis.line.x = element_line(size = 1),legend.title = element_text(size = 12,face = "bold"))+
  labs(fill="Phylum")+
  scale_y_continuous(expand = c(0, 0))+
  facet_grid(~Group,scales = "free_x")
p1
plotdf$Group<-factor(plotdf$Group,levels = c("N","I+N","I+H","P+N","P+H"))
p2<-ggplot(filter(plotdf,Classify=="Family"),aes(Samples,Abundance,fill= Taxon))+
  geom_bar(stat = "identity", width=1)+
  theme_minimal()+scale_fill_manual(values=newpalette2)+
  theme( axis.line = element_line(arrow = arrow()),axis.title.y = element_text(size = 12),
         axis.title.x = element_text(size = 12),
         legend.text = element_text(size = 12),axis.text.x = element_text(size = 12),
         axis.text.y = element_text(size = 12),axis.line.y = element_line(size = 1),
         axis.line.x = element_line(size = 1),legend.title = element_text(size = 12,face = "bold"))+
  labs(fill="Family")+
  scale_y_continuous(expand = c(0, 0))+
  facet_grid(~Group,scales = "free_x")

p2
p3<-ggplot(filter(plotdf,Classify=="Family"),aes(Samples,Abundance,fill= Taxon))+
  geom_bar(stat = "identity", width=1, col='black')+
  theme_minimal()+scale_fill_manual(values=newpalette2)+
  theme( axis.line = element_line(arrow = arrow()),axis.title.y = element_text(size = 12),
         axis.title.x = element_text(size = 12),
         legend.text = element_text(size = 12),axis.text.x = element_text(size = 12),
         axis.text.y = element_text(size = 12),axis.line.y = element_line(size = 1),
         axis.line.x = element_line(size = 1),legend.title = element_text(size = 12,face = "bold"))+
  labs(fill="Family")+
  scale_y_continuous(expand = c(0, 0))+
  facet_grid(~Group,scales = "free_x")

p2
p3<-ggplot(filter(plotdf,Classify=="Genus"),aes(Samples,Abundance,fill= Taxon))+
  geom_bar(stat = "identity", width=1, col='black')+
  theme_minimal()+scale_fill_manual(values=newpalette2)+
  theme( axis.line = element_line(arrow = arrow()),axis.title.y = element_text(size = 12),
         axis.title.x = element_text(size = 12),
         legend.text = element_text(size = 12),axis.text.x = element_text(size = 12),
         axis.text.y = element_text(size = 12),axis.line.y = element_line(size = 1),
         axis.line.x = element_line(size = 1),legend.title = element_text(size = 12,face = "bold"))+
  labs(fill="Genus")+
  scale_y_continuous(expand = c(0, 0))+
  facet_grid(~Group,scales = "free_x")

p3
##pie plot
df<-read.csv("Phylum_abundance_mean.csv",header = T)
piedata <- melt(df,id.vars="Phylum",variable.name="Group",value.name = "Ratio")
piedata$Group<-factor(piedata$Group,levels = c("N","I.N","I.H","P.N","P.H"))
pie = ggplot(piedata, aes(x = "", y = Ratio, fill = Phylum)) +
  geom_bar(stat = "identity", width = 1,color="white") +    
  coord_polar(theta = "y") + 
  labs(x = "", y = "", title = "") + 
  theme(axis.ticks = element_blank()) + 
  theme(legend.title = element_blank(), legend.position = "top") + 
  theme(axis.text.x = element_blank()) + 
  facet_grid(~Group)+
  theme(axis.text.x = element_blank())
pie+ scale_fill_pander()+
  theme_stata()
pie+ scale_fill_economist(breaks = piedata$Phylum)
pie+ scale_fill_fivethirtyeight(breaks = piedata$Phylum)
pie+ scale_fill_ptol(breaks = piedata$Phylum)
pie+ scale_fill_gdocs(breaks = piedata$Phylum)
pie+ scale_fill_hc(breaks = piedata$Phylum)
pie+ scale_fill_solarized(breaks = piedata$Phylum)
pie+ scale_fill_manual(breaks = piedata$Phylum,values = c("#FF7F01","#3FE0CF","#E42125","#994EA3","#fffb34"))


