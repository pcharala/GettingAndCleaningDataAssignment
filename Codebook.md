Codebook
================================
In the following the main steps for the creation of a tidy subset of 'UCI HAR Dataset' using 'run_analysis.R' script are briefly described.

* Initially, the script checks whether the necessary files of the dataset are present inside the folder 'UCI HAR Dataset' of the working directory and throws an error message in case there something is missing.

```
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
```

* 'X' (data), 'y' (activities) and 'subject' variables are loaded as tables for both training and testing set. Feature and activity labels are also loaded. Training and testing sets are merged in data frame 'total.data' using function cbind().

```
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
```

* Features corresponding to mean and standard deviation values of measurements are found using function grep() on the feature labels loaded from features.txt file. An appropriate regular expression is formulated including 'mean' and 'std' substrings. It is noted that 'meanFreq' and 'angle' features are ommited.
```
## find features corresponding to mean or std values.
## angle/meanFreq features are ommited
idx <- grep('mean[^F]|std',features.labels[,2])
total.data <- total.data[,c(1,2,2+idx)]
```

* The columns of 'total.data' are named after appropriate humanly-read names. Original feature labels are used for feature columns after invalid R characters (parentheses, minus, comma) have been ommited.
```
## assign descriptive names to the columns of dataset by ommiting parentheses,
## converting '-' to '_' and ',' to '.' in original feature labels
features.cleanlabels <- features.labels[idx,]
features.cleanlabels[,2] <- gsub("[()]","",features.cleanlabels[,2])
features.cleanlabels[,2] <- gsub("[-]","_",features.cleanlabels[,2])
features.cleanlabels[,2] <- gsub("[,]",".",features.cleanlabels[,2])
colnames(total.data) <- c('subject','activity',as.character(features.cleanlabels[,2]))
```

* The activity numbers is activity column of 'total.data' are replaced by their humanly-read labels.
```
## replace activity number codes by activity labels
total.data$activity <- activity.labels[total.data$activity,2]
```

* The average for each feature over each subject-activity pair is found using function aggregate() that splits the data into subsets based on subject-activity values and computes a summary statistic (mean) for each.
```
## find average over each subject-activity pair
data.avg <- aggregate(total.data[,3:length(total.data)], 
                            by=list(subject=total.data$subject,activity=total.data$activity),
                            mean)
```

* Finally, the tidy dataset is saved as a .csv file in the working directory and a success message is printed.
```
## export tidy dataset as .csv file
write.csv(data.avg,"UCI_HAR_tidy.csv",row.names=F)
print(paste0("Success! Tidy dataset saved as: ",getwd(),"/UCI_HAR_tidy.csv"))
```
