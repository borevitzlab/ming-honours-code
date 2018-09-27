# set working dir to script dir
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# load data
data <- read.delim("output.tsv")
pots <- read.csv("../gc_treatment_list.csv")
treatments <- read.csv("../treatments.csv")
read_filter_counts <- read.csv("read_filter_counts.csv")

# fix formatting
pots$PotID <- as.character(pots$PotID)

# Fix taxa names (always in alphabetic order)
levels(data$taxa.name) <- c("213.6", "36.1", "36.8", "65.7")

# Get proportion for counts
read_filter_counts$normed <- read_filter_counts$after/read_filter_counts$before

# Add proportional counts to data
data$filter_prop <- read_filter_counts$normed[match(data$sample, read_filter_counts$sample)]

# Add treatment labels
data$pot <- substr(data$sample, start = 1, stop = 3)
data$treatment <- pots$Treatment[match(data$pot, pots$PotID)]
data$tray <- pots$Tray[match(data$pot, pots$PotID)]
data$treatment_label <- treatments$Label[match(data$treatment, treatments$Treatment)]

# Make groupings for later
data$sample_type <- substr(data$sample, start = 4, stop = 5)
# relabel groupings
data$sample_type[data$sample_type=="S"] <- "Sand"
data$sample_type[data$sample_type=="R"] <- "Nodules"
data$sample_type[data$sample_type=="C"] <- "Root-only control"

data$group <- paste(data$sample_type, ", ", data$treatment_label, sep = "")
# special cases
data$group[data$group==", NA"] <- "Culture mix"
data$group[data$group=="l, NA"] <- "Soil slurry inoculum"

# Add sample total counts
data <- within(data,sample_total <- ave(count.estimate,sample,FUN=sum))

# Add proportions of counts
data$norm_error <- data$error.estimate/data$sample_total
#data <- within(data,norm_counts <- ave(count.estimate,sample,FUN=function(x) ((x)/sum(x))))
data$norm_counts <- data$count.estimate/data$sample_total

# Filter out low levels of reads
filtered <- data[data$sample_total>20,]

# Format axis labels 
library(limma)
filtered$sample <- paste(filtered$sample, " (", filtered$tray,", ",percent(filtered$filter_prop),  ") ", 
                         filtered$treatment_label, sep="")

# Special axis labels
filtered$sample[grep("^ref", filtered$sample)] <- paste("Original culture mix:", percent(filtered$filter_prop[grep("^ref", filtered$sample)]))
filtered$sample[grep("^soil", filtered$sample)] <- paste("Soil slurry inoculum:", percent(filtered$filter_prop[grep("^soil", filtered$sample)]))
filtered$sample[grep("^sim_combo1k", filtered$sample)] <- paste("1000 reads simulated equal mix:", percent(filtered$filter_prop[grep("^sim_combo1k", filtered$sample)]))
filtered$sample[grep("^sim_combo10k", filtered$sample)] <- paste("10000 reads simulated equal mix:", percent(filtered$filter_prop[grep("^sim_combo10k", filtered$sample)]))
#filtered$sample <- paste(filtered$sample, " (", filtered$sample_total, ")", sep = "")

# Create matrix for heatmap
library(reshape2)
heatmap <- acast(filtered, sample~taxa.name, value.var="norm_counts")

# Select only significant counts
threshold <- 0.05

# make labels
library(scales)
filtered$norm_counts <- percent(filtered$norm_counts)
filtered$norm_error <- percent(filtered$norm_error)
filtered$norm_counts <- paste(filtered$norm_counts, "\n ±", filtered$norm_error)
filtered$norm_counts[filtered$raw.pval<threshold] <- paste(filtered$norm_counts[filtered$raw.pval<threshold], "\n*")

heatmap_sig <- acast(filtered, sample~taxa.name, value.var="norm_counts")



# Draw heatmap
library(pheatmap)
library(RColorBrewer)
library(grid) 

# from https://stackoverflow.com/a/15506652
# For pheatmap_1.0.8 and later:
draw_colnames_45 <- function (coln, gaps, ...) {
  coord = pheatmap:::find_coordinates(length(coln), gaps)
  x = coord$coord - 0.5 * coord$size
  res = textGrob(coln, x = x, y = unit(1, "npc") - unit(3,"bigpts"), vjust = 1, hjust = 0, rot = -45, gp = gpar(...))
  return(res)}

## 'Overwrite' default draw_colnames with your own version 
assignInNamespace(x="draw_colnames", value="draw_colnames_45",
                  ns=asNamespace("pheatmap"))

pheatmap(heatmap, treeheight_row = 0, display_numbers=heatmap_sig, width=900,
         treeheight_col = 0, color=colorRampPalette(brewer.pal(n = 7, name = "Spectral"))(100))

# Process groupings
library(dplyr)
library(metap)

n <- length(unique(data$pot)) # get actual n of samples

grouped <- filtered %>% 
  group_by(taxa.name, group) %>% 
  summarise(counts=sum(count.estimate), se=poolVar(error.estimate, n=n)$var, pval=sum(raw.pval),
            norm_counts=sum(count.estimate)/sum(sample_total), 
            norm_se=poolVar(error.estimate, n=n)$var/sum(sample_total))

heatmap_grouped <- acast(grouped, group~taxa.name, value.var="norm_counts")

# make individual heatmap labels
grouped$norm_counts <- percent(grouped$norm_counts)
grouped$norm_se <- percent(grouped$norm_se)
grouped$norm_counts <- paste(grouped$norm_counts, "\n ±", grouped$norm_se)
grouped$norm_counts[grouped$pval<threshold] <- paste(grouped$norm_counts[grouped$pval<threshold], "\n*")
  
heatmap_grouped_labels <- acast(grouped, group~taxa.name, value.var="norm_counts")

pheatmap(heatmap_grouped, treeheight_row = 0, display_numbers=heatmap_grouped_labels, width=900,
         treeheight_col = 0, color=colorRampPalette(brewer.pal(n = 7, name = "Spectral"))(100))
