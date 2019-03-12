# basic word count exercise using Resilient Distributed Datasets in Spark
rdd = spark.sparkContext.textFile("C:/bible.txt")
import re
def wordclean(x):
    return re.sub("[^a-zA-Z0-9\s]+","",x).lower().strip()
def numclean(x):
    return re.sub("[0-9]+","",x)
cleanrdd = rdd.map(wordclean).map(numclean)
splitrdd = cleanrdd.flatMap(lambda x: x.split())
reduced_rdd = splitrdd.map(lambda x: (x,1)).reduceByKey(lambda x,y: x+y)
sorted_rdd = reduced_rdd.sortBy(lambda x: x[1], ascending=False)