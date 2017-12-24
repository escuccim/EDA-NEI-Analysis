## Function multiplot taken from http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
    library(grid)
    
    # Make a list from the ... arguments and plotlist
    plots <- c(list(...), plotlist)
    
    numPlots = length(plots)
    
    # If layout is NULL, then use 'cols' to determine layout
    if (is.null(layout)) {
        # Make the panel
        # ncol: Number of columns of plots
        # nrow: Number of rows needed, calculated from # of cols
        layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                         ncol = cols, nrow = ceiling(numPlots/cols))
    }
    
    if (numPlots==1) {
        print(plots[[1]])
        
    } else {
        # Set up the page
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
        
        # Make each plot, in the correct location
        for (i in 1:numPlots) {
            # Get the i,j matrix positions of the regions that contain this subplot
            matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
            
            print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                            layout.pos.col = matchidx$col))
        }
    }
}

# Read the data in if it doesn't already exist
if(!exists("NEI")){
    NEI <- readRDS("summarySCC_PM25.rds")    
}
if(!exists("SCC")){
    SCC <- readRDS("Source_Classification_Code.rds")    
}

if(!exists("vehicle_codes")){
    # Find what sources contain "Vehicle" to isolate motor vehicles
    vehicle <- grepl("Vehicle", SCC$SCC.Level.Two)
    vehicle_codes <- SCC[vehicle,]$SCC
}

if(!exists("pm25_vehicle")){
    # Filter out emissions with codes related to motor vehicles
    pm25_vehicle <- subset(NEI, SCC %in% vehicle_codes)
    
}

# Filter out emissions for Baltime City and LA
balt_vehicle <- subset(pm25_vehicle, fips == "24510")
balt_vehicle$City.Name <- as.factor("Baltimore City")

la_vehicle <- subset(pm25_vehicle, fips == "06037")
la_vehicle$City.Name <- as.factor("Los Angeles")

# Combine the two city's data
labalt_vehicle <- rbind(balt_vehicle,la_vehicle)

# Sum by year and city
vehicle_totals  <- aggregate(labalt_vehicle$Emissions, by=list(Year=labalt_vehicle$year, City=labalt_vehicle$City.Name, fips=labalt_vehicle$fips), FUN=sum)
names(vehicle_totals) <- c("Year","City","fips","Emissions")

# Add percentage change from previous year
vehicle_totals$Per.Change = vehicle_totals$Emissions/lag(vehicle_totals$Emissions,1) - 1
vehicle_totals[5,5] = NA
vehicle_totals[1,5] = NA

# Make the plots
library(ggplot2)
png(filename="plot6.png",width=640,height=640)
total <- with(vehicle_totals, qplot(Year, Emissions, main="Total Emissions",geom=c("point","smooth"), facets=City ~ .)) + geom_smooth(method="lm",se=FALSE,color="red",linetype="dashed",size=0.2)
percent <- with(vehicle_totals, qplot(Year, Per.Change, main="% Change",geom=c("point","smooth"), facets=City ~ .)) + geom_smooth(method="lm",se=FALSE,color="red",linetype="dashed",size=0.2)

multiplot(total, percent, cols=2)
dev.off()
