# set working dir to script dir
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# read data
germination <- read.csv("germination.csv")
treatments <- read.csv("treatments.csv")

# subset data for just plants
germination <- germination[treatments$Host=="Yes",]
germination$Normed <- germination$Germinated/germination$Original
germination$Label <- treatments[treatments$Host=="Yes",]$Inoculation

# create probabilities
germination$ExpProportion <- germination$Original/sum(germination$Original)

chisq.test(germination$Germinated, p=germination$ExpProportion)

library(ggplot2)
ggplot(germination, aes(x = Label, y = Normed*100, )) +
  geom_bar(stat="identity", width = 0.7) +
  labs(x = "Treatment", y = "% germinated", fill = "Symscore") 
