library(dplyr)
library(ggplot2)
library(gridExtra)
library(lubridate)
library(tidyverse)  # data manipulation
library(cluster)    # clustering algorithms
library(factoextra) # clustering algorithms & visualization

orders = read.csv("C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/olist_orders_dataset.csv",header = TRUE)
# "order_id" unique identifier of the order.                      
# "customer_id" key to the customer dataset. Each order has a unique customer_id.                   
# "order_status" Reference to the order status (delivered, shipped, etc).                  
# "order_purchase_timestamp" Shows the purchase timestamp.      
# "order_approved_at" Shows the payment approval timestamp.            
# "order_delivered_carrier_date" Shows the order posting timestamp. When it was handled to the logistic partner. 
# "order_delivered_customer_date" Shows the actual order delivery date to the customer.
# "order_estimated_delivery_date" Shows the estimated delivery date that was informed to customer at the purchase moment.
customers = read.csv("C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/olist_customers_dataset.csv",header = TRUE)
# "customer_id" key to the orders dataset. Each order has a unique customer_id.              
# "customer_unique_id" unique identifier of a customer.       
# "customer_zip_code_prefix" first five digits of customer zip code
# "customer_city" customer city name          
# "customer_state" customer state  
payments = read.csv("C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/olist_order_payments_dataset.csv",header = TRUE)
# "order_id" unique identifier of an order.             
# "payment_sequential" a customer may pay an order with more than one payment method. If he does so, a sequence will be created to accommodate all payments.   
# "payment_type" method of payment chosen by the customer.         
# "payment_installments" number of installments chosen by the customer. 
# "payment_value" transaction value.       
items = read.csv("C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/olist_order_items_dataset.csv",header = TRUE)
# "order_id" order unique identifier            
# "order_item_id" sequential number identifying number of items included in the same order.       
# "product_id" product unique identifier          
# "seller_id" seller unique identifier           
# "shipping_limit_date" Shows the seller shipping limit date for handling the order over to the logistic partner. 
# "price" item price               
# "freight_value" item freight value item (if an order has more than one item the freight value is splitted between items)      
products = read.csv("C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/olist_products_dataset.csv",header = TRUE)
# "product_id" unique product identifier                 
# "product_category_name" root category of product, in Portuguese.      
# "product_name_lenght" number of characters extracted from the product name.        
# "product_description_lenght" number of characters extracted from the product description. 
# "product_photos_qty" number of product published photos        
# "product_weight_g" product weight measured in grams.           
# "product_length_cm" product length measured in centimeters.          
# "product_height_cm" product height measured in centimeters.          
# "product_width_cm" product width measured in centimeters.  

#Creating dataset of Recency, Frequency, & Payment via joins 
#obtaining frequency of purchases by customer_unique_id
freq = customers %>% inner_join(orders, by = "customer_id") %>%
  group_by(customer_unique_id) %>%
  summarise(
    freq = n()
  )

#obtaining payment sums of purchases by customer_id
payments2 = orders  %>% inner_join(payments, by = "order_id") %>%
  group_by(customer_id) %>%
  summarise(
    payments = sum(payment_value)
  )
#adding a recency of purchase from 3/16/2021
orders$recency = difftime(date(orders$order_purchase_timestamp),dmy("4/9/2016"),units = "days")

#obtaining minimum recency of purchase by customer_unique_id
rec = customers %>% inner_join(orders, by = "customer_id") %>%
  group_by(customer_unique_id) %>%
  summarise(
    recency = min(recency)
  )
# save(rec, file = "C:/Users/OJElGhiran/Desktop/Candidate Test/Brazil/rec.RData")

#obtaining total payment value by customer_unique_id
pymt = customers %>% inner_join(payments2, by = "customer_id") %>%
  group_by(customer_unique_id) %>%
  summarise(
    pymnt = sum(payments)
  )

#creating RFM data set from freq, rec, and pymt by customer_unique_id
RFM1 = freq %>% inner_join(rec) %>% inner_join(pymt) %>%
  group_by(customer_unique_id) %>%
  summarise(
    recency = sum(recency)
    ,frequency = sum(freq)
    ,pymt = sum(pymnt)
  )
RFM1 = RFM1[-which(RFM1$pymt == 0), ]
RFM1 = as.data.frame(RFM1)

#EDA
#Recency visual
a1 = ggplot(RFM1, aes( y = recency))+geom_boxplot()+ggtitle("Recency Unscaled")
a2 = ggplot(RFM1, aes( x = recency))+geom_histogram(binwidth = 1)+
  geom_vline(xintercept = c(min(RFM1$recency),quantile(RFM1$recency,0.25),median(RFM1$recency),quantile(RFM1$recency,0.75),max(RFM1$recency)))+
  ggtitle("Recency Unscaled")
grid.arrange(a1,a2,nrow = 1)
summary(RFM1$recency)

#Frequency visual
c1 = ggplot(RFM1, aes( x = frequency))+geom_histogram(binwidth = 1)+ggtitle("Frequency Unscaled")
c2 = ggplot(RFM1, aes( y = frequency))+geom_boxplot()+ggtitle("Frequency Unscaled")
grid.arrange(c1,c2,nrow = 1)
summary(RFM1$frequency)

#Payment visual
b1 = ggplot(RFM1, aes( y = pymt))+geom_boxplot()+ggtitle("Pymt (Monetary) Unscaled")
b2 = ggplot(RFM1, aes( x = pymt))+geom_histogram(binwidth = 1)+
  ggtitle("Pymt (Monetary) Unscaled")
grid.arrange(b1,b2,nrow = 1)

#Min-max normalization
RFM1$recency[which(RFM1$recency == 0)] = 0.5
RFM1$recency_inv = 1/RFM1$recency
RFM1$recency_inv_scaled = scale(RFM1$recency_inv)
RFM1$frequency_scaled = scale(RFM1$frequency)
RFM1$pymt_scaled = scale(RFM1$pymt)
RFM1$recency_inv_minmax = (RFM1$recency_inv - min(RFM1$recency_inv))/(max(RFM1$recency_inv)-min(RFM1$recency_inv))
RFM1$frequency_minmax = (RFM1$frequency-min(RFM1$frequency))/(max(RFM1$frequency)-min(RFM1$frequency))
RFM1$pymt_minmax = (RFM1$pymt-min(RFM1$pymt))/(max(RFM1$pymt)-min(RFM1$pymt))
RFM1$recency_minmax = (RFM1$recency - min(RFM1$recency))/(max(RFM1$recency)-min(RFM1$recency))

#Kmeans Clustering
#recency_minmax
ggplot(RFM1, aes(x =recency, y = 0 ))+geom_point()

set.seed(1)

k3 <- kmeans(RFM1[,c(13)], centers = 3, nstart = 25)

p3 <- fviz_cluster(k3, geom = "point",  data = RFM1[,c(13)]) + ggtitle("k = 3")

finalz <- kmeans(RFM1[,c(13)], 3, nstart = 25)
print(finalz)

fviz_cluster(finalz, data = RFM1[,c(13)])

RFM1$recency_minmax_cluster = finalz$cluster
#Extract the clusters and add to our initial data to do some descriptive statistics at the cluster level:
t1 = RFM1 %>%
  group_by(recency_minmax_cluster) %>%
  summarise(
    min = min(recency_minmax)
    ,med = median(recency_minmax)
    ,mean = mean(recency_minmax)
    ,max = max(recency_minmax)
  )

RFM1$recency_minmax_cluster = 0

RFM1$recency_minmax_cluster = ifelse(RFM1$recency_minmax >= max(t1$min),1, ifelse(RFM1$recency_minmax <= min(t1$max),3,2))

RFM1 %>%
  group_by(recency_minmax_cluster) %>%
  summarise(
    min = min(recency)
    ,med = median(recency)
    ,mean = mean(recency)
    ,max = max(recency)
  )
ggplot(RFM1, aes(x = recency_minmax, y = 0, color = as.factor(recency_minmax_cluster)))+geom_point()+ggtitle("Recency_minmax Clustered") + theme(legend.position = "none")
ggplot(RFM1, aes(x = recency, y = 0, color = recency_minmax_cluster))+geom_point()


#frequency_minmax
set.seed(1)
summary(RFM1$frequency_minmax)

k3 <- kmeans(RFM1[,c(11)], centers = 3, nstart = 25)

p3 <- fviz_cluster(k3, geom = "point",  data = RFM1[,c(11)]) + ggtitle("k = 3")

finalz <- kmeans(RFM1[,c(11)], 3, nstart = 25)
print(finalz)

fviz_cluster(finalz, data = RFM1[,c(11)])

RFM1$frequency_minmax_cluster = finalz$cluster
#Extract the clusters and add to our initial data to do some descriptive statistics at the cluster level:
t1 = RFM1 %>%
  group_by(frequency_minmax_cluster) %>%
  summarise(
    min = min(frequency_minmax)
    ,med = median(frequency_minmax)
    ,mean = mean(frequency_minmax)
    ,max = max(frequency_minmax)
  )
RFM1$frequency_minmax_cluster = 0 
RFM1$frequency_minmax_cluster = ifelse(RFM1$frequency_minmax >= max(t1$min), 3, ifelse(RFM1$frequency_minmax <= min(t1$max),1,2))

RFM1 %>%
  group_by(frequency_minmax_cluster) %>%
  summarise(
    min = min(frequency)
    ,med = median(frequency)
    ,mean = mean(frequency)
    ,max = max(frequency)
  )
ggplot(RFM1, aes(x = frequency_minmax, y = 0, color = as.factor(frequency_minmax_cluster)))+geom_point()+ggtitle("Frequency_minmax Clustered")
ggplot(RFM1, aes(x = frequency, y = 0, color = as.factor(frequency_minmax_cluster)))+geom_point()


#pymt_minmax
set.seed(1)
summary(RFM1$pymt_minmax)

k4 <- kmeans(RFM1[,c(12)], centers = 4, nstart = 25)

p4 <- fviz_cluster(k4, geom = "point",  data = RFM1[,c(12)]) + ggtitle("k = 4")

finalz <- kmeans(RFM1[,c(12)], 4, nstart = 25)
print(finalz)

fviz_cluster(finalz, data = RFM1[,c(12)])

RFM1$pymt_minmax_cluster = as.factor(finalz$cluster)
#Extract the clusters and add to our initial data to do some descriptive statistics at the cluster level:
t1 = RFM1 %>%
  group_by(pymt_minmax_cluster) %>%
  summarise(
    min = min(pymt_minmax)
    ,med = median(pymt_minmax)
    ,mean = mean(pymt_minmax)
    ,max = max(pymt_minmax)
  )

RFM1$pymt_minmax_cluster = 0 
RFM1$pymt_minmax_cluster = ifelse(RFM1$pymt_minmax >= max(t1$min), 4, ifelse(RFM1$pymt_minmax <= min(t1$max), 1,ifelse(RFM1$pymt_minmax >= t1[[order(t1$min)[c(2)],2]] & RFM1$pymt_minmax<=t1[[order(t1$max)[c(2)],5]], 2,3)))
RFM1 %>%
  group_by(pymt_minmax_cluster) %>%
  summarise(
    min = min(pymt)
    ,med = median(pymt)
    ,mean = mean(pymt)
    ,max = max(pymt)
  )
ggplot(RFM1, aes(x = pymt_minmax, y = 0, color = as.factor(pymt_minmax_cluster)))+geom_point()+ggtitle("Pymt_minmax Clustered")
ggplot(RFM1, aes(x = pymt, y = 0, color = pymt_minmax_cluster))+geom_point()

#Create RFM_Score
RFM1$RFM_score = RFM1$recency_minmax_cluster + RFM1$frequency_minmax_cluster + RFM1$pymt_minmax_cluster 

#Summarize customer base by RFM_Score
RFM1 %>% group_by(RFM_score) %>%
  summarise(
    count = n(),
    min_rec = min(recency),
    mean_rec = mean(recency),
    med_rec = median(recency),
    max_rec = max(recency),
    min_freq = min(frequency),
    mean_freq = mean(frequency),
    med_freq = median(frequency),
    max_freq = max(frequency),
    min_pymt = min(pymt),
    mean_pymt = mean(pymt),
    med_pymt = median(pymt),
    max_pymt = max(pymt)
    
  )

#Creating segments from RFM_scores
RFM1$Segment = ifelse(RFM1$RFM_score <= 4, 1, ifelse(RFM1$RFM_score <= 6, 2, ifelse(RFM1$RFM_score == 7, 3, 4)))

#Summarize customer base by Segment
RFM1 %>% group_by(Segment) %>%
  summarise(
    count = n(),
    min_rec = min(recency),
    mean_rec = mean(recency),
    med_rec = median(recency),
    max_rec = max(recency),
    min_freq = min(frequency),
    mean_freq = mean(frequency),
    med_freq = median(frequency),
    max_freq = max(frequency),
    min_pymt = min(pymt),
    mean_pymt = mean(pymt),
    med_pymt = median(pymt),
    max_pymt = max(pymt)
    
  )

#Customer proportions by RFM_Score & visualize
table(RFM1$RFM_score)
round((table(RFM1$RFM_score)/nrow(RFM1))*100,1)

ggplot(RFM1, aes(x= RFM_score)) + 
  geom_bar(aes(y = ..prop.., fill = factor(..x..)), stat="count") +
  # geom_text(aes( label = scales::percent(..prop..),
  #                y= ..prop.. ), stat= "count", vjust = -.5) +
  geom_text(aes(label = scales::percent(round((..count..)/sum(..count..),3)),
                y= ((..count..)/sum(..count..))), stat="count",
            vjust = -.25) + 
  labs(y = "Percent", fill="RFM_score") +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = as.character(RFM1$RFM_score),breaks = RFM1$RFM_score) + 
  ggtitle("RFM Score")

#Customer proportions by Segment & visualize
ggplot(RFM1, aes(x= Segment)) + 
  geom_bar(aes(y = ..prop.., fill = factor(..x..)), stat="count") +
  geom_text(aes( label = scales::percent(..prop..),
                 y= ..prop.. ), stat= "count", vjust = -.5) +
  labs(y = "Percent", fill="RFM_cat") +
  scale_y_continuous(labels = scales::percent) + 
  scale_fill_discrete(name = "Segment", labels = c("At Risk", "Needs Attention", "Promising","Champions")) + 
  ggtitle("Targeted Marketing Segments")