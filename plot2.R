# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

# subset out the data for FIPS 24510
BaltimoreCity <- subset(NEI, fips == "24510")

# Sum up the totals by year
BaltimoreTotalsByYear <- aggregate(BaltimoreCity$Emissions, by=list(Year=BaltimoreCity$year), FUN=sum)

# Label the columns 
names(BaltimoreTotalsByYear) <- c("Year","Emissions")

# Make the plot
png(filename="plot2.png",width=640,height=640)
plot(BaltimoreTotalsByYear,type="l")
title(main="PM2.5 Emissions in Baltimore City")
dev.off()