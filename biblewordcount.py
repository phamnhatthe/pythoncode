# Counting Bible words using RDD from Spark. Built for being run from terminal
from pyspark import SparkConf, SparkContext
import re
import sys
conf = SparkConf().setMaster("local").setAppName("WordCount")
sc = SparkContext(conf = conf)

rdd = sc.textFile("file:///fslhome/thepham/bible.txt")

def case(x): return re.sub("[^a-zA-Z0-9\s]+","",x).lower().strip()
def numchange(x): return re.sub('[0-9]+','',x)
rdd2 = rdd.map(lambda x : case(x))
rdd3 = rdd2.map(lambda x : numchange(x))
rdd4 = rdd3.flatMap(lambda l: l.split(' '))
rdd5 = rdd4.map(lambda w: (w, 1)).reduceByKey(lambda x,y: x+y)
rdd6 = rdd5.filter(lambda x : x[0] not in ' ')
rdd7 = rdd6.sortBy(lambda a: a[1], ascending = False)
print(rdd7.take(20))
rdd7.saveAsTextFile("count3")
sc.stop()
