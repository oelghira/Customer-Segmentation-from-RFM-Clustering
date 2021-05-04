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
