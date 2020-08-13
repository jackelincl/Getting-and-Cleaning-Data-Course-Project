#Getting and Cleaning Data Course Project

#Loading packages
library(data.table)

#Setting path and url to download zip files
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataset.zip"))
unzip(zipfile="dataset.zip")

#Loading activities, features, desired features (mean and standard deviation) and measurements
activitylabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("index", "activityname"))
activitylabels[["activityname"]] <- tolower(activitylabels[["activityname"]])
activitylabels[["activityname"]] <- gsub(pattern = "_", replacement = " ", activitylabels[["activityname"]])
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featurenames"))
meanstd <- grep("(mean|std)\\(\\)", features[, featurenames])
measurements <- features[meanstd, featurenames]
measurements <- gsub('[()]', '', tolower(measurements))

#Loading train dataset
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, meanstd, with = FALSE]
setnames(train, colnames(train), measurements)
trainactivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("activity"))
trainsubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("subject"))
train <- cbind(trainsubjects, trainactivities, train)
train[["activity"]] <- factor(train[, activity], levels = activitylabels[["index"]], labels = activitylabels[["activityname"]])

#Loading test dataset
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, meanstd, with = FALSE]
setnames(test, colnames(test), measurements)
trainactivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("activity"))
trainsubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("subject"))
test <- cbind(trainsubjects, trainactivities, test)
test[["activity"]] <- factor(test[, activity], levels = activitylabels[["index"]], labels = activitylabels[["activityname"]])

#Merging train and test dataset
merged <- rbind(train, test)

merged[["subject"]] <- as.factor(merged[, subject])
result <- melt(data = merged, id = c("subject", "activity"))
result <- dcast(data = result, subject + activity ~ variable, mean)

fwrite(x = result, file = "tidydata.txt", quote = FALSE)



