# Recency-Frequency-Monetary-Clustering-of-Online-Customers
I describe the methods used to cluster customers of a Brazilian online retailer by their recency, frequency, and monetary value of purchases

## Introduction
In today's world of online retail, it is critical to a business's survival to know who their customers are and how those customers behave. Today's consumers develop a relationship with the brands and retailers they choose to patronize. In order for that relationship to not end in a break up, retailers must provide a much more personal touch with targeted and personalized communication that speaks to the individual needs of each customer. The problem with a personalized approach is that online retailers can have such a wide range of consumers as opposed to a brick in mortar store in a fixed location. Creating something personalized for each individual is a nearly impossible task, but the good news is that we can gain an indepth understanding of the customer base by clustering customers with similar behavior! In this example, I will show how clustering to achieve a better targeted marketing approach can be done using customers' recency of last purchase, how frequent they have shopped, and how much they have spent with a Brazilian Amazon type of online retailer.  

## Data  
https://www.kaggle.com/olistbr/brazilian-ecommerce

All data was provided via Kaggle using the link above. The datasets and descriptions of the relevant data used are as follows:  

**olist_orders_dataset**  
  "order_id" unique identifier of the order.                        
  "customer_id" key to the customer dataset. Each order has a unique customer_id.                   
  "order_purchase_timestamp" Shows the purchase timestamp.     

**olist_customers_dataset**   
  "customer_id" key to the orders dataset. Each order has a unique customer_id.              
  "customer_unique_id" unique identifier of a customer.       
  "customer_state" customer state.
  
**olist_order_payments_dataset**    
  "order_id" unique identifier of an order.             
  "payment_sequential" a customer may pay an order with more than one payment method. If he does so, a sequence will be created to accommodate all payments.   
  "payment_type" method of payment chosen by the customer.         
  "payment_installments" number of installments chosen by the customer.  
  "payment_value" transaction value.    
  
**olist_order_items_dataset**    
  "order_id" order unique identifier            
  "order_item_id" sequential number identifying number of items included in the same order.       
  "product_id" product unique identifier.   

**olist_products_dataset**  
  "product_id" unique product identifier.                 
  "product_category_name" root category of product, in Portuguese. 

## Exploratory Data Analysis (EDA)  
### Recency
![Recency Unscaled](https://user-images.githubusercontent.com/46107551/116838477-86380c00-ab9c-11eb-9268-39d0572e5132.png)
The last day of a purchase in the data was made on April 9th, 2016. This date as the 0th date and all other purchase dates were given a numeric recency based on many days behind the 0th date they were made. For example a purchase made on April 1st, 2016 had a numeric recency of 8 (i.e 8 days in the past) and a purchase made on April 9th, 2015 had a numeric recency of 365 (i.e. 365 days in the past).   
 
The data table below shows that most shoppers in this dataset have not revisited the site in over a year since thier last purchase! Given this fact, almost all clusters or groupings will have a very long tail for recency. 
| Min | Q2  | Median  |Mean | Q3  | Max |
| --- |:---:| ---:|:---:| ---:|---:|
| 0   | 372 | 501|482.2| 607|773|


![Frequency Unscaled](https://user-images.githubusercontent.com/46107551/116838518-a7006180-ab9c-11eb-9970-63c892ac3b1d.png)
An overwhelming 96% of customers only shopped with this online retailer only once! Given this fact there will not be much variation when it comes to clustering customers based on recency. 

The data below shows the summary statistics of the frequency of purchases by the customers in the dataset. 
| Min | Q2  | Median  |Mean | Q3  | Max |
| --- |:---:| ---:|:---:| ---:|---:|
| 1   | 1 | 1|1.035| 1|17|


![Payment Unscaled](https://user-images.githubusercontent.com/46107551/116838528-ad8ed900-ab9c-11eb-802f-2caf57a043b2.png)
As with frequency, payment (pymt) is heavily skewed to the right with a long tail from under $200 reaching just under $14K. 

The data table below shows the summary statistics and that 75% of all customers in the dataset spent less than $200 with the retailer. 
| Min | Q2  | Median  |Mean | Q3  | Max |
| --- |:---:| ---:|:---:| ---:|---:|
| $9.59   | $63.13 | $108| $166.6| $183.53| $13,644.08|

Given the amount of variation in frequency and monetary value (pymt) of customers, clustering will have to take into consideration questions of practicality. It could very easily be the case that more clusters makes sense from a K-means perspective, but those additional clusters could be the same as "splitting hairs" in terms of what is practical. Knowing what we know, when it comes to clustering one has to ask themselves, "Does it really make sense to treat these customers differently?"  

## K-means Clustering
Before diving into the K-means clustering algorithm. Each of the 3 variables (recency, frequency, payment) were scaled to put each variable into a similar context. Each variable was normalized using min-max scaling which results in each variable represented on a scaled from 0 to 1. In min-max scaling the individual observation was transformed by the following formula:  
![min-max](https://latex.codecogs.com/gif.latex?x%27%20%3D%20%5Cfrac%7Bx%20-%20min%28x%29%7D%7Bmax%28x%29-min%28x%29%7D)

After normalizing each variable, we begin to implement the K-means alogorithm for each of our variables. It is assumed here, that the reader understands the methods behind the K-means algorithm, and details of the mechanics behind it have been omitted. 

**Recency**  
![Recency Git](https://user-images.githubusercontent.com/46107551/116965362-97a41580-ac7b-11eb-9924-e06c6abb4c2f.png)
Based on the scree plot of the scaled recency variable, it appears that the optimal number of clusters is somewhere between 2 and 4. Noticing the spread of the unscaled recency variable is between 0 (adjusted to 0.5 for the min-max calculation) and 773, it did not make sense to use only 2 clusters. Using 2 clusters would result in clusters separated at the midpoint treating customers who shopped within 387 days in one category and further out customers in another. Using 4 clusters seems to be adding clusters without creating additional value. 3 seems to be the optimal number in that the algorithm treats the most recent customers in one cluster, those haven't shopped in over a year in another, and those that made their last purchase almost 2 years ago or longer in another.

**Frequency**
![Frequency Git](https://user-images.githubusercontent.com/46107551/116965377-9ffc5080-ac7b-11eb-8190-678486eb614e.png)
The reoccuring theme here is that the optimal number of clusters from our scree plot lies between 2 and 4. Given that we know 96% of customers made only 1 purchase, it does make some sense to use only 2 clusters. This would result in 1 cluster of 1 time shoppers and another of mutiple time shoppers. In a practical sense, this is too simple of a solution and assumes there is no other differences between customers who shopped multiple times. Using 4 clusters would treat the outlier customer who shopped 17 times as their own cluster. This would also produce no additional value to have a cluster devoted to only 1 shopper. Thus the optimal number of clusters alogorithmically and practically seems to be 3. 1 cluster for 1 time shoppers, another for those that made 2 or 3 purchases, and a final cluster for those that shopped 4 or more times. 

**Monetary**
![Payment Git](https://user-images.githubusercontent.com/46107551/116965387-a68ac800-ac7b-11eb-916f-f3c00fbc12b6.png)
The monetary value of customers is where determing the optimal number of clusters gets interesting. From our EDA, we know the spread of payment amount is very wide ranging from less than $10 to almost $14K. We also know that most customers are not high spenders given the frequency plot with most of its mass closer to 0 than the tail at the right (see EDA section). Too few clusters can treat a majority of customers as one segment and assumes there is not much variability in those lower amounts. On the basis of what can best be applied to a targeted marketing campaign, I lean towards 4 clusters as the optimal number. Using 4 clusters separates the majority of shoppers into distinct categories of low spenders, moderate spenders, high spenders, and the highest spenders that could be purchasing not only for themselves but businesses and entire families. 

## From Clusters to Targeted Marketing Segments
The next steps are to add up the cluster "scores" from our previous excercise to get one final score made up of components from recency, frequency, and monetary value of purchases. In order to keep things consistent the highest value in each cluster was the highest number of clusters. Thus the highest spending customers were in cluster 4 for monetary value and the most frequent shoppers were in cluster 3 for frequency. For recency the scale was reversed in that the most recent shoppers were in cluster 3 and the customers who shopped furthest in the past are less attainable and in cluster 1. 

Adding our cluster scores results in the following break down of our customer base:  
| RFM Score | Count  | Min Recency  |Median Recency | Mean Recency  | Max Recency |  | Min Frequency  | Median Frequency  |Mean Frequency | Max Frequency  |  |Min Pymt  |Median Pymt | Mean Pymt  | Max Pymt |
| --- |:---:| ---:|:---:| ---:|---:| --- |:---:| ---:|:---:| ---:|---:|---:|:---:| ---:|---:|
| 3   | 28,251 | 553|636| 637|773|| 1   | 1 | 1 |1| |9.59|87.4 |94.5|200 |
| 4   | 34,642 | 367|492| 500|739|| 1   | 1 |1.01 |3| |10.1|103 |131|585 |
| 5   | 25,381 | 0.5|318| 336|724|| 1   | 1 |1.03 |3| |11.6|117 |178|1,571 |
| 6   | 6,068 | 29|315| 329|732|| 1   | 1 |1.2 |3| |38.2|305 |446|7,275 |
| 7   | 1,499 | 30|290| 294|688|| 1   | 1 |1.51 |6| |73.5|669 |785|13,664 |
| 8   | 225 | 30|265| 271|702|| 1   | 2 |1.92 |9| |320|1,294 |1,541|6,929 |
| 9   | 26 | 179|293| 291|494|| 2   | 4 |4.31 |17| |604|1,104 |1,684|7,572 |
| 10   | 1 | 287|287| 287|287|| 4   | 4 |4 |4| |1,761|1,761 |1,761|1,761 |

|RFM Cat| RFM Score | Count  | Min Recency  |Median Recency | Mean Recency  | Max Recency |  | Min Frequency  | Median Frequency  |Mean Frequency | Max Frequency  |  |Min Pymt  |Median Pymt | Mean Pymt  | Max Pymt |
| --- |:---:|:---:| ---:|:---:| ---:|---:| --- |:---:| ---:|:---:| ---:|---:|---:|:---:| ---:|---:|
|At Risk | 3,4   | 62,893 | 367|567| 561|773|| 1   | 1 | 1 |3| |9.59|94.5|115|585 |
|Needs Attention| 5,6   | 31,449 | 0.5|317| 335|732|| 1   | 1 |1.06 |3| |11.6|149 |230|7,275 |
|Promising| 7   | 1,499 | 30|290| 294|688|| 1   | 1 |1.51 |6| |73.5|669 |785|13,664 |
|Champions| 8,9,10   | 252 | 30|268| 273|702|| 1   | 2 |2.17 |17| |320|1,262 |1,557|7,275 |

