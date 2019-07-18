setwd("F:\\16S _results20190711")
library(vegan)
otu<-read.csv("NMDS_otu.csv",row.names =1,stringsAsFactors = T)
otu <- data.frame(t(otu))
nmds1 <- metaMDS(otu, distance = 'bray', k = 4)
summary(nmds1)
nmds1.stress <- nmds1$stress
nmds1.point <- data.frame(nmds1$point)
nmds1.species <- data.frame(nmds1$species)
write.csv(nmds1.point, 'nmds.sample.csv')
nmds_plot <- nmds1
nmds_plot$species <- {nmds_plot$species}[1:10, ]
plot(nmds_plot, type = 't', main = paste('Stress =', round(nmds1$stress, 4)))
stressplot(nmds_plot, main = 'Shepard 图')
gof <- goodness(nmds_plot)
plot(nmds_plot,type = 't', main = '拟合度')
points(nmds_plot, display = 'sites', cex = gof * 200, col = 'red')

group <- read.delim('metada.txt', sep = '\t', stringsAsFactors = FALSE)
nmds1 <- metaMDS(otu, distance = 'bray', k = 2)
sample_site <- nmds1.point[1:2]
sample_site$names <- rownames(sample_site)
names(sample_site)[1:3] <- c('NMDS1', 'NMDS2','sample')
sample_site <- merge(sample_site, group, by = 'sample', all.x = TRUE)

library(ggplot2)
library(ellipse)
pdf("NMDS2.pdf")
ggplot(data=sample_site, aes(x=NMDS1, y=NMDS2, col=group,shape=group))+ 
     geom_point(size=3) +
    stat_ellipse() +
     theme_bw() +
     labs(title = "NMDS Plot (Stress = 0.1579259)")+
    scale_color_grey()+
      scale_color_manual(values = c('#3B4992','#EE0000','#008B45','#631879','#631879'))
dev.off()
