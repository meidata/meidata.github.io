---
layout: post
title: "kaggle competition instacart take away"
output: html_document
date: 2017-08-16
---

  The second kaggle competition I've participated just ended yesterday, unfortunately due to a wrong selection of the submission and bad local cross-validation strategy, I ended up in the top 14% without any medals. But I have learned so much from this competition and also from others kagglers. And since this competition a.k.a 'busines problem' can be replicated somehow somewhere in the real world, I decided to write a summery report of the features and the take away of this competition.
 
#### Problem formulation

<img src="{{url}}/images/instacart_problem.png" alt="picutre" style="width: 800px;"/> 

<br><br>
  By using the transactional data of users, this Instacart market basket analysis competition aimed to predict which product will a user buy again over time. The business problem here could be translated into 'Can I know my customer well enough to prepare a grocery list in their account so that they don't have to manually add them next time?', and related to that, which is out of scope of the competition, but we can also find out the favorite product of client or the potential product that the customer will like.
  
  *[Instacart](https://www.instacart.com/) is a grocery odering and delivery app based in US.* 
<br><br>
<img src="{{url}}/images/instacart_data.png" alt="picutre" style="width: 800px;"/>  

  The dataset contains the transcational information of when a user has brought which product. so bascially this predicition problem could be solved either by using a recommendation system algorithme (which I've tried but it failed to work) or by using a binary classifier algorithme.
<br><br>

  

