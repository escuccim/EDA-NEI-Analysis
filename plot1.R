# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

# Sum up the totals by year
total <- aggregate(NEI$Emissions, by=list(Year=NEI$year), FUN=sum)

# Label the columns 
names(total) <- c("Year","Emissions")

# Divide the emissions by 1,000,000
total$Emissions <- total$Emissions / 1000000

# Make the plot
png(filename="plot1.png",width=640,height=680)
plot(total,type="l",ylab="PM2.5 Emissions (millions)")
title(main="US Total PM2.5 Emissions by Year")
dev.off()