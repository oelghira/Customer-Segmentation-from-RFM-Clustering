# Recency-Frequency-Monetary-Clustering-of-Online-Customers
I describe the methods used to cluster customers of a Brazilian online retailer by customers recency, frequency, and monetary value of purchases

## Introduction
In today's world of online retail, it is critical to a businesses survival to know who their customers are and how those customers behave. Today's consumers develop a relationship with the brands and retailers they choose to do business with. In order for that relationship to not end in a break up, retailers must provide a much more personal touch with targeted and personalized communication that speaks to the individual needs of each customer. The problem with a personalized approach is that online retailers can have such a wide range of consumers as opposed to a brick in mortar store in a fixed location. Creating something personalized for each individual is a nearly impossible task, but the good news is that we can gain an indepth understanding of the customer base by clustering customers with similar behavior! In this example, I will show how clustering to achieve a better targeted marketing approach can be done using customers' recency of last purchase, how frequent they have shopped, and how much they have spent with a Brazilian Amazon type of online retailer.  

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

