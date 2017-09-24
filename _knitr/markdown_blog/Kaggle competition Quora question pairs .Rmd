---
layout: post
title: "[Kaggle] Quora question pairs summary"
output: html_document
date: 2017-08-14 
---

  Quora question pairs competition ended two months ago in kaggle, it was my first serious kaggle competition and as final result I got a bronze medal for being in the top 8% position in the scoreboard.

  Frankly speaking, this competition is so fierce that I remembered one Saturday before the competition ended, I was in top 3%, and when I checked on the following Monday I was pushed downed to top 7% already, and there are some really good kaggle masters competing there which really show me the huge gap between my model and theirs. That's the reason why I decide to write this blog to share the some take-aways from this competition and some useful features drawn from the winner solution shared in the discussion board after the competition ended.

  * *[Quora](https://en.wikipedia.org/wiki/Quora "wikipedia") is a question-and-answer site where questions are asked, answered, edited and organized by its community of users. The website has [100 million unique visitors](https://www.quora.com/How-many-people-use-Quora-7 "how many people use Quora") per month as march of 2016.*

  * *[kaggle](https://www.kaggle.com/) is a platform for data science competitions. As of May 2016, Kaggle had over [536,000 registered users](https://en.wikipedia.org/wiki/kaggle "wikipedia").*
<br><br>

#### Problem formulation

<img src="{{url}}/images/quora_kaggle.png" alt="picutre" style="width: 800px;"/>
<br><br>
  The Objective of the competition is to identify the duplicate question on the question dataset by predicting the probability of similarity between two questions.
 <br><br> 
   <img src="{{url}}/images/train.png" alt="picutre" style="width: 800px;"/>
<br><br>
  This is the training dataset provided by Quora which contains 404290 pairs of questions (question1,question2), along with a column 'is_duplicate' with value 0 indicating this pair of question is duplicate and value 1 being non-duplicate. Same goes with the test dataset with 2345796 pairs of questions.
  <br><br>
   <img src="{{url}}/images/test.png" alt="picutre" style="width: 800px;height: 260px"/>
<br><br>
 Ok, it seems to me pretty clear that it is a classification problem, so we need to use the model built from the training dataset to predict if the pairs of questions in test dataset is duplicate or not.
<br><br>

#### My approaches: When we talk about building models...

  The first thing to tackle a text mining problem is to turn the word into numeric representation so that the algorithm can 'understand' the word. To interpret the text there are usually two methods : 1)TFIDF 2)word2vec. For the TFIDF part I used bigram to get the words weighting and a pre-trained word2vec model for the word vector. My final model is a simple xgb model with 47 features under python 3.5 environment.

  *The 'To try' part is resumed from the winning solution in the [discussion board](https://www.kaggle.com/c/quora-question-pairs/discussion 'discussion') after the competition ended*



**1. Preprocessing (no surprise here..)**

    1. Lowercase
    2. Remove question mark
    3. Lemmatization
    4. Snowball Stemmer

To try:

    1. Spelling correction
    2. Name Entity Recognizer (spaCy)
    3. Use [Textacy](https://github.com/chartbeat-labs/textacy) for preprocessing

**2. Feature generation**

Feature essentially plays a big part in this competition, the features I've used can be categorized as following:

1.NLP text features: The descriptive measure of two sentences.

    1.	Length of the question1, question2
    2.	Difference of the length of two questions ( -/+unique words)
    3.	Ratio of the length of two questions( -/+unique words)
    4.	Character-wise length of the question1, question2 (with/without stopwords)
    5.	Character-wise ratio of length of the question1, question2
    6.	Number of words in question1, question2
    7.	Number of common words in question1, question2
    8.	Ratio of number of common words dived by the length of two questions (removed stopwords)
    9.	Ratio of common words tfidf scores dived by the total tfidf scores of two questions 
            (-/+ stopwords)
    10.	Number of total unique words in two questions (with/without stopwords)
    11.	same_start_word/same_last_word : binary features

*To try:*

    1.  Longest common subsequences (lcs) of both questions
    2.  POS-based featuress
<br><br>


2.Distance features (mostly inspired by @abhishek, it really guided me into the competition): The distance between two vectors.

    The vectors of words are constructed from pre-trained google news w2v model, I tried to build my own w2v model by using all the questions in both dataset but it didn't outperform the pre-trained one, I guess the reason is quite obvious due to the size of the corpus.
  
     1. Jaccard similarity
     2. Cosine similarity
     3. Euclidean distance
     4. Minkowski distance
     3. Levenshtein Distance 
        (package *fuzzywuzzy* :string similarity/partial string similarity/token sort)
     4. Word mover's distance
     
*To try:*
  
     1. Use G Love for vectors embedding (and recompute the similarity)
     
3.Graphical features:
  
  I have absolutely zero knowledge at that time that this kind of features can be applied into a NLP competition which turns out to be a extremely important feature (thanks to Shankara Srivastava's idea of pagerank feature). In the social network analysis, you can see a lot of this kind of graphical analysis as well.
  
  <img src="{{url}}/images/a.jpg" alt="pic" style="width: 400px;"/>
  
  Basically,every question is node in the graph, the degree of node here can be seen as the frequency of this question, and the common neighbors for the two node.
  
  
*To try:*

      1.maxclique features of edges
      2.maxclique features of nodes
      3.unique neighbors
      4.paths of length n between q1 & q2

**3. Imbalanced dataset**

  In the training dataset, since the percentage of duplicate question is 36.9%, it's important to rebalance the dataset, and there are lots of methods to deal with this problem i.e. oversample (oversample the minority class) , undersample (undersampling the majority class). But instead of using the two sampling methods above, i used the class weight in the xgb Matrix argument to let the model treat two class differently. It turned out to be quite effective, which helped me at least with 0,02 improvement.


**4. Conclusion**

  I should definitely explore more in the graphical features since it proved to reveal efficiently the connection between the two questions, and also create more features based on different pre-processed step (raw, stemmed, cleaned, stopwords only, stopwords removed, etc). 

  I spent almost all the weekends of this two months in this competition, Learned a lot from the great people there, let's just say besides learning the theory in data science, being able to apply it is also critical, I think Kaggle is good platform to bridge the gap between this two aspects. Have fun kaggling!
