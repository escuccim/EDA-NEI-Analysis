# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

# Find what sources contain "Coal"
coal <- grepl("[Cc]oal",SCC$Short.Name)
coal_codes <- SCC[coal,]$SCC

# Filter out emissions with codes related to coal
pm25_coal <- subset(NEI, SCC %in% coal_codes)

# Aggregate totals by year
coal_totals  <- aggregate(pm25_coal$Emissions, by=list(Year=pm25_coal$year), FUN=sum)
names(coal_totals) <- c("Year","Emissions")

# Scale the emissions
coal_totals$Emissions = coal_totals$Emissions / 1000

# Make the plots using ggplot
library(ggplot2)
png(filename="plot4.png",width=640,height=640)
plot <- with(coal_totals, qplot(Year, Emissions, geom=c("point","smooth"),main="US Coal Emissions by Year",ylab="PM2.5 Emissions (thousands)"))
print(plot)
dev.off()