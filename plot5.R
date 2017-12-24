# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

# Find what sources contain "Vehicle" to isolate motor vehicles
vehicle <- grepl("Vehicle", SCC$SCC.Level.Two)
vehicle_codes <- SCC[vehicle,]$SCC

# Filter out emissions with codes related to motor vehicles
pm25_vehicle <- subset(NEI, SCC %in% vehicle_codes)

# Filter out emissions for Baltime City - FIPS = 24510
balt_pm25_vehicle <- subset(pm25_vehicle, fips == "24510")

vehicle_totals  <- aggregate(balt_pm25_vehicle$Emissions, by=list(Year=balt_pm25_vehicle$year), FUN=sum)
names(vehicle_totals) <- c("Year","Emissions")


# Make the plots using ggplot
library(ggplot2)
png(filename="plot5.png",width=640,height=640)
plot <- with(vehicle_totals, qplot(Year, Emissions, geom=c("point","smooth"),main="Baltimore City Vehicle Emissions by Year",ylab="PM2.5 Emissions"))
print(plot)
dev.off()