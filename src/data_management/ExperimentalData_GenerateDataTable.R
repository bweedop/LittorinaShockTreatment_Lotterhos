packages <- c("randomizr")
packages.to.install <- packages[!(packages %in% installed.packages()[,"Package"])]
if (length(packages.to.install)) {
    install.packages(packages.to.install)
}
invisible(lapply(packages, require, character.only = TRUE))

###################
# Generate labels #
###################

# Set seed for reproducibility
set.seed(90)

# treatments <- two letter indicators for three different treatments
treatments <- c("HS", "CS", "NT")

# block <- two digit block indicator with leading zeros
block <- sprintf("%02d", seq(1, 12))

# sample.n <- four digit sample indicator with leading zeros
sample.n <- sprintf("%04d", seq(1, 1080))

# pops <- two letter indicators for the two different populations
pops <- c("MA", "RI")

# locations <- 
# locations <- c()

# spp <- two letter indicators for the three different species
spp <- c("LL", "LS", "LO")
# genus_species <- full name of genus and species to be matched with spp in data
genus_species <- c("littorina_littorea",
                   "littorina_saxatalis",
                   "littorina_obtusata")

# pop.spp <- vector of pops and spp combined the for the amount that will be collected
tmp <- expand.grid(treatments, pops, spp, block)
label.permute <- sprintf('%s_%s_%s_%s', tmp[,1], tmp[,2], tmp[,3], tmp[,4])

################################################
# Randomize Samples into Treatments and Blocks #
################################################

# sample.indicators <- combined labels which are randomly seperated into 
#                      treatments and blocks.
sample.indicators <- paste(as.character(complete_ra(N = 1080, 
                                                    conditions = unique(label.permute))), 
                           sample.n, sep = "_")


######################################
# Generate data frame for data entry #
######################################

data <- data.frame("block" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 4) ),
                   "sample_n" = sample.n,
                   "sample_indicator" = sample.indicators,
                   "genus_species" = genus_species[match(unlist(lapply(strsplit(sample.indicators, split="_"), "[", 3) ), spp)],
                   "population" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 2) ),
                   "collection_location" = NA,
                   "treatment" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 1) ),
                   "shell_height" = NA,
                   "shell_width" = NA,
                   "wet_weight" = NA,
                   "buoyant_weight" = NA,
                   "respiration_measured" = FALSE,
                   "respiration" = NA,
                   "treatmentDay1_survived" = TRUE,
                   "treatmentDay2_survived" = TRUE,
                   "treatmentDay3_survived" = TRUE,
                   "tissue_collected" = FALSE,
                   stringsAsFactors = FALSE)

###################
# Save data frame #
###################

write.table(data, "data/experimental/LittorinaSppTreatmentData.txt")                   
