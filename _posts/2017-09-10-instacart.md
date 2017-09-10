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
      1. number of users has ordered this product
      2. number of users has reordered this product
      3. user reorder ratio of this product : #1 / #2
      4. number of times this product has been ordered
      5. number of times this product has been reordered
      6. product reorder ratio: #4 / #5
      7. product reorder probability : numbers of products has been purchased the second time / numbers of products                                         has been purchased the first time
      8. mean add to cart order of product 
      <br><br>
      
      Aisle-wised:
      1. number of times this aisle has been ordered
      2. number of times this aisle has been reordered
      3. aisle reorder ratio: #1 / #2
      4. mean add to cart order of aisle
      <br><br>
      
      Department-wised:
      1. number of times this department has been ordered
      2. number of times this department has been reordered
      3. department reorder ratio: #1 / #2
      4. mean add to cart order of department
      <br><br>
  * `User features`:
      1. number of orders has been placed by the users
      2. how long users have been ordering from website (user tenure)
      3. average orders days since prior orders
      4. number of products in total the user has brought
      5. number of unique products/aisles/departments the user has brought (users taste variance)
      6. average basket size of the user
      7. proportion of the reorder product of users
      <br><br>
  * `User x Item features`:
      1. number of times the user has brought this product
      2. #1/total orders number
      3. first/last order number of this user buying this product
      4. average add to cart order of the product
      5. Total order number - last orders of this product (capture recency)
      6. Is this product has been purchased in the last three order of the user (capture recency)
      <br><br>
      
  This is pretty much the features I've generated, among the features, the most important feature selected by the model is the **avaerge add to cart order of the product** and **Is this product has been purchased in the last three order of the user** which capture the recency of the behavioral pattern of the users.
 
  The important finding in this feature engineering part is:
  
  1) Remove highly correlated features (corr > 95%) before putting the variables into the xgboost models, even thought the xgboost models handle perfectly the correlation with the same importance due to the way it splits the features, but by removing the the correlated variables, the model could get similar or better performance by choosing only one of them and not to mention the decrease of the computing time.
  
  2) Kaggler @raddar shared one of his way to examine if the variable is important at one [post](https://www.kaggle.com/c/instacart-market-basket-analysis/discussion/36859) which I found really useful:     "Take new feature, bin it into lets say 50 attributes. Now take your best model out-of-fold predictions. Then for each bin, calculate mean target rate (if you are using binary model) and mean predicted probability of your classifier. if you see high difference between mean and predicted values in any of attributes (which has significant amount of observations), the feature is likely to reduce the binomial variance if included in the new model." in two words, for continuous features, split them into 20-50 buckests and measure diversity by the mean of the target.
  
  3) Add binary attribute feature of the product (gluten-free/asian food/organic/pet), for example, if a user has a cat/dog, it's possible that he/she will reorder product for the pet, or if he/she likes asian food or organic food, it's more likely that they will more it more frequently than others,etc.
  
  4) I didn't implement product text feature in the model,but people who got a good final score have used this feature, in summary here it's their approach (summary from [@SVJ24](https://www.kaggle.com/c/instacart-market-basket-analysis/discussion/38120),[@plantsgo](https://github.com/plantsgo/Instacart-Market-Basket-Analysis/blob/master/products_Word2Vec_features.py)):
  
  * Product name length
  * Product name rarity: mean of idf of each word in a product (capture people who like exotic products)
  * Product vector: 
    Treat each order as a sentence and product_id as words in that sentence.
    **group by order_id, sentence = each product of this order, product_id as words.**
    
    <img src="{{url}}/images/p2v.png" alt="picutre" style="width: 600px;"/> 
    
    For exemple, in order #1, user brought product 49302, 11109, 10246, 49683, 43633, 13176,etc, so each product_id will be transformed into string and serve as a word to put into the w2v model to learn their vecotr representation, and use pca to reduce the dimension. 
     
  * User vector : 
    Treat each user as a document and order_id as sentence in that document.**group by user_id, sentence = each order of this user, product_id/aisle_id/deprtment_id as words.**
    <img src="{{url}}/images/d2v_1.png" alt="picutre" style="width: 600px;"/> 
    <img src="{{url}}/images/d2v_2.png" alt="picutre" style="width: 600px;"/> 
    
    Treat every orders as sentences and product_id/aisle_id/deprtment_id as words, and use user_id as the document label, so one document is ensemble user orders history and the document id is the user id. at the end you can get the word-embeddings for a user.

  

  
  
  
  
  
  
  Exactly. I strongly agree with what you said.

For many times when I tune my lightGBM model, I used early stopping round as a convenient way to get a quick glance at feature importance. However, this parameter very likely leads to situations like : 1) training stops too early(e.g., stopping round statistics(auc, log-loss) much worse than final round, thus should not be stopped at all; 2) Sometimes when I ran into situation 1, I plunged the model back in and choose to continue training, and get much better result. 3) worse result when you have eta < 0.03 4) Adding more feature, choose to continue training from previous model gives significantly better results

It seems mistakes accumulate in lightGBM when you have > 500 rounds, but I can't say for sure.

 design a representative cross-validation framework 
 
 
 
