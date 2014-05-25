## ckeck if necessary files exist
dat.dir <- "UCI HAR Dataset/"

actLabels.file <- paste0(dat.dir,"activity_labels.txt")
features.file <- paste0(dat.dir,"features.txt")
Xtrain.file <- paste0(dat.dir,"train/X_train.txt")
ytrain.file <- paste0(dat.dir,"train/y_train.txt")
subtrain.file <- paste0(dat.dir,"train/subject_train.txt")
Xtest.file <- paste0(dat.dir,"test/X_test.txt")
ytest.file <- paste0(dat.dir,"test/y_test.txt")
subtest.file <- paste0(dat.dir,"test/subject_test.txt")

expr <- file.exists(actLabels.file, features.file, Xtrain.file, ytrain.file,
                    subtrain.file, Xtest.file, ytest.file, subtest.file)

if (!all(expr)) {
    stop("Necessary files do not exist!")
} else{
    print("All necessary files exist")
}

## load files
X.train <- read.table(Xtrain.file)
activity.train <- read.table(ytrain.file)
subject.train <- read.table(subtrain.file)
X.test <- read.table(Xtest.file)
activity.test <- read.table(ytest.file)
subject.test <- read.table(subtest.file)
activity.labels <- read.table(actLabels.file)
features.labels <- read.table(features.file)

## merge train and test datasets
X <- rbind(X.train, X.test)
activity <- rbind(activity.train, activity.test)
subject <- rbind(subject.train, subject.test)
total.data <- cbind(subject,activity,X)

## find features corresponding to mean or std values.
## angle/meanFreq features are ommited
idx <- grep('mean[^F]|std',features.labels[,2])
total.data <- total.data[,c(1,2,2+idx)]

## assign descriptive names to the columns of dataset by ommiting parentheses,
## converting '-' to '_' and ',' to '.' in original feature labels
features.cleanlabels <- features.labels[idx,]
features.cleanlabels[,2] <- gsub("[()]","",features.cleanlabels[,2])
features.cleanlabels[,2] <- gsub("[-]","_",features.cleanlabels[,2])
features.cleanlabels[,2] <- gsub("[,]",".",features.cleanlabels[,2])
colnames(total.data) <- c('subject','activity',as.character(features.cleanlabels[,2]))

## replace activity number codes by activity labels
total.data$activity <- activity.labels[total.data$activity,2]

## find average over each subject-activity pair
data.avg <- aggregate(total.data[,3:length(total.data)], 
                            by=list(subject=total.data$subject,activity=total.data$activity),
                            mean)

## export tidy dataset as .csv file
write.csv(data.avg,"UCI_HAR_tidy.csv",row.names=F)
print(paste0("Success! Tidy dataset saved as: ",getwd(),"/UCI_HAR_tidy.csv"))