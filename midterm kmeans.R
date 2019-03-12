# Code for cleaning data to perform kmeans clustering and Hierarchical Agglomerative Clustering.
# The original data contained lots of outliers and was unsuitable for these machine learning
# techniques. The Hierarchical Agglomerative Clustering tree was uninterpretable.
# These cleaning techniques below cleared the data of outliers outside 4 standard deviations
eeg <- read.csv(file="EEGEyeState.csv",header=TRUE)

# take out outlier
eeg2<-eeg[-c(899,10387,11510,13180),]
str(eeg2)

lower<-as.numeric(0)
upper<-as.numeric(0)
assigned<-list()
for (i in 1:14){
  #means[i]<-mean(eeg2[,i])
  #s.d[i]<-sd(eeg2[,i])
  
  lower[i]<-mean(eeg2[,i]) - 4*sd(eeg2[,i])
  upper[i]<-mean(eeg2[,i]) + 4*sd(eeg2[,i])
  assigned[[i]]<-which(eeg2[,i] < lower[i])
  assigned[[14+i]]<-which(eeg2[,i] > upper[i])
  assignment<-unique(unlist(assigned))
  eeg2_new<-eeg2[-assignment,]
}
###### eeg2_new is the data now. it is clean
k<-kmeans(eeg2_new,2)
str(as.factor(k$cluster))
cluster<-k$cluster
cluster<-replace(cluster, cluster==1, 0)
cluster<-replace(cluster,cluster==2,1)
mean(cluster == eeg2_new$eyeDetection)
