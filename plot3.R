# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

# subset out the data for FIPS 24510
if(!exists("BaltimoreCity")){
    BaltimoreCity <- subset(NEI, fips == "24510")
}

# Convert type to a factor
BaltimoreCity$type <- factor(BaltimoreCity$type)

# Make the totals by Year and Type
totals <- aggregate(BaltimoreCity$Emissions, by=list(Year=BaltimoreCity$year, Type=BaltimoreCity$type), FUN=sum)
# label the columns
names(totals) <- c("Year","Type","Emissions")

# Split by type
by_type <- split(totals, totals$Type)

# Make the plots using ggplot
library(ggplot2)
png(filename="plot3.png",width=640,height=640)
plot <- ggplot(totals, aes(y=Emissions, x=Year)) + geom_point() + geom_smooth(method="lm",se=FALSE) + facet_grid(Type ~ .) + labs(title="Baltimore City PM2.5 Emissions By Type")
print(plot)
dev.off()