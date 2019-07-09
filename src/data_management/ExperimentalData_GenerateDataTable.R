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
block <- sprintf("%02d", seq(1, 6))

# sample.n <- four digit sample indicator with leading zeros
sample.n <- sprintf("%04d", seq(1, 1080))

# pops <- two letter indicators for the two different populations
pops <- c("MA", "RI")

# dates <- get dates that pretreatment respiration measurements will be taken
dates <- seq(from = as.Date("2019/06/29"), to = as.Date("2019/08/01"), by  = 1)
dates <- dates[!weekdays(dates) %in% c("Saturday", "Sunday")]

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
                           sample.n, 
                           sep = "_")

######################################
# Generate data frame for data entry #
######################################

data <- data.frame("Block" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 4) ),
                   "Seatable_ID" = NA,
                   "Sample_N" = sample.n,
                   "Sample_Indicator" = sample.indicators,
                   "Genus_Species" = genus_species[match(unlist(lapply(strsplit(sample.indicators, split = "_"), "[", 3) ), spp)],
                   "Population" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 2) ),
                   "Collection_Location" = NA,
                   "Treatment" = unlist(lapply(strsplit(sample.indicators, split="_"), "[", 1) ),
                   "ShellHeight" = NA,
                   "ShellWidth" = NA,
                   "WetWeight" = NA,
                   "PreTreatment_Respiration_MeasureDate" = NA,
                   "PreTreatment_Respiration" = NA,
                   "PostTreatment_Respiration_Measured" = FALSE,
                   "PostTreatment_Respiration" = NA,
                   "TreatmentDay1_Survived" = TRUE,
                   "TreatmentDay2_Survived" = TRUE,
                   "TreatmentDay3_Survived" = TRUE,
                   "Tissue_Collected" = FALSE,
                   "EggsProduced" = FALSE,
                   stringsAsFactors = FALSE)

data <- data[order(data$Block), ]
data$PreTreatment_Respiration_MeasureDate <- rep(dates, each = 45)

# bloxks - full list of blocks that will be used to randomize the seatable assignment
blocks <- data$Block
# block_m_each <- parameter settings for randomization. 
#   6 rows for 6 blocks and 60 in each of the three seatables.
block_m_each <- rbind(c(60, 60, 60),
                      c(60, 60, 60),
                      c(60, 60, 60),
                      c(60, 60, 60),
                      c(60, 60, 60),
                      c(60, 60, 60))
# Z - Temporary variable that will be used to store the seatable ID
Z <- block_ra(blocks = blocks, block_m_each = block_m_each)
data$Seatable_ID <- Z

###################
# Save data frame #
###################

write.table(data, 
            "data/experimental/LittorinaSppTreatmentData.csv", 
            sep = ",", 
            row.names = FALSE)