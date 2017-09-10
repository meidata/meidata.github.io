---
layout: post
title: "kaggle competition instacart take away"
output: html_document
date: 2017-08-16
---

  The second kaggle competition I've participated just ended yesterday, unfortunately due to a wrong selection of the submission and bad local cross-validation strategy, I ended up in the top 14% without any medals. But I have learned so much from this competition and also from others kagglers. And since this competition a.k.a 'business problem' can be replicated somehow somewhere in the real world, I decided to write a summery report of the features and the take away of this competition.
 
#### 1. Problem formulation

<img src="{{url}}/images/instacart_problem.png" alt="picutre" style="width: 800px;"/> 

<br><br>
  This Instacart market basket analysis competition aimed to predict **which product will a user buy again over time**. The business problem here could be translated into 'Can I know my customer well enough to prepare a grocery list in their account so that they don't have to manually add them next time?', and related to that, but a bit out of scope of the competition, we can also find out the favorite product of client or the potential product that the customer will like.
  
  *[Instacart](https://www.instacart.com/) is a grocery odering and delivery app based in US.* 
<br><br>
<img src="{{url}}/images/instacart_data.png" alt="picutre" style="width: 800px;"/>  

  In general, the dataset contains the history of the transnational information of when a user has brought which product.

  Full dataset schema is as followed : [source](https://gist.github.com/jeremystan/c3b39d947d9b88b3ccff3147dbcf6c6b)

`orders` (3.4m rows, 206k users):
* `order_id`: order identifier
* `user_id`: customer identifier
* `eval_set`: which evaluation set this order belongs in (see `SET` described below)
* `order_number`: the order sequence number for this user (1 = first, n = nth)
* `order_dow`: the day of the week the order was placed on
* `order_hour_of_day`: the hour of the day the order was placed on
* `days_since_prior`: days since the last order, capped at 30 (with NAs for `order_number` = 1)

`products` (50k rows):
* `product_id`: product identifier
* `product_name`: name of the product
* `aisle_id`: foreign key
* `department_id`: foreign key

`aisles` (134 rows):
* `aisle_id`: aisle identifier
* `aisle`: the name of the aisle

`deptartments` (21 rows):
* `department_id`: department identifier
* `department`: the name of the department

`order_products__SET` (30m+ rows):
* `order_id`: foreign key
* `product_id`: foreign key
* `add_to_cart_order`: order in which each product was added to cart
* `reordered`: 1 if this product has been ordered by this user in the past, 0 otherwise

where `SET` is one of the four following evaluation sets (`eval_set` in `orders`):
* `"prior"`: orders prior to that users most recent order (~3.2m orders)
* `"train"`: training data supplied to participants (~131k orders)
* `"test"`: test data reserved for machine learning competitions (~75k orders)

#### 2. The approach 

  Since the evaluation metric of the competition is F1-score and the purpose is to predict the item that users will reorder again, my approach is feature engineering + logloss-xgboost model + F1-optimization.

* Feature engineering (frequency/distribution and interaction based features)

  * `Item (Product/aisle/department) features`:
      <br><br>
      Product-wised: 
      1. how many users has ordered this product
      2. how many users has reordered this product
      3. user reorder ratio of this product : #1 / #2
      4. how many times this product has been ordered
      5. how many times this product has been reordered
      6. product reorder ratio: #4 / #5
      7. product reorder probability : numbers of products has been purchased the second time / numbers of products                                         has been purchased the first time
      8. mean add to cart order of product 
      <br><br>
      
      Aisle-wised:
      1. how many times this aisle has been ordered
      2. how many times this aisle has been reordered
      3. aisle reorder ratio: #1 / #2
      4. mean add to cart order of aisle
      <br><br>
      
      Department-wised:
      1. how many times this department has been ordered
      2. how many times this department has been reordered
      3. department reorder ratio: #1 / #2
      4. mean add to cart order of department
      <br><br>
  * `User features`:
      1. how many orders has been placed by the users
      2. how many days users have been active in the website
      3. average orders days since prior orders
      4. how many products in total the user has brought
      5. how many unique products the user has brought
      6. average basket size of the user
      7. proportion of the reorder product of users
      <br><br>
  * `User x Item features`:
      1. how many times the user has brought this product
      2. #1/total orders number
      3. first/last order number of this user buying this product
      4. average add to cart order of the product
      5. Total order number - last orders of this product (capture recency)
      6. Is this product has been purchased in the last three order of the user (capture recency)
      <br><br>
      
  This is pretty much the features I've generated, among the features, the most important feature selected by the xbgboos is the **avaerge add to cart order of the product** and **Is this product has been purchased in the last three order of the user** which capture the recency of the behavioral pattern of the users.
 
  The important finding in this feature engineering part is:
  
  1) Try to remove highly correlated features (corr > 95%) before putting the variables into the xgboost models, even thought the xgboost models handle perfectly the correlation with the same importance due to the way it splits the features, but by removing the the correlated variables, the model could get similar or better performance by choosing only one of them and also the computing time.
  
  2)
 
 
 
