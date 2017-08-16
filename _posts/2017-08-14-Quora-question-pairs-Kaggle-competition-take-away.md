---
layout: post
title: "Quora question pairs Kaggle competition take away"
output: html_document
date: 2017-08-14 
---

  Two months ago, kaggle Quora question pairs competition ended, it was my first serious kaggle competition and as final result i got a bronze medal for being in the top 8% position in the scoreboard.

  Frankly speaking, this competition is so fierce that i remembered one Saturday before the competition ended, i was in top 3%, and when i checked on the following Monday i was pushed downed to top 7% already, and there are some really good kaggle masters competing there which really show me the huge gap between my model and theirs. That's the reason why i decide to write this blog to share the some take-away from this competition and some useful features drawn from the winner solution shared in the discussion board after the competition ended.

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

  The first thing to tackle a text mining problem is to turn the word into numeric representation so that the algorithm can 'understand' the word. To interpret the text there are usually two methods : 1)TFIDF 2)word2vec. For the TFIDF part i used bigram to get the words weighting and a pre-trained word2vec model for the word vector. My final model is a simple xgb model with 47 features under python 3.5 environment.

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

    The vectors of words are constructed from pre-trained google news w2v model, i tried to build my own w2v model by using all the questions in both dataset but it didn't outperform the pre-trained one, i guess the reason is quite obvious due to the size of the corpus.
  
     1. Jaccard similarity
     2. Cosine similarity
     3. Euclidean distance
     4. Minkowski distance
     3. Levenshtein Distance 
        (package *fuzzywuzzy* :string similarity/partial string simliarity/token sort)
     4. Word mover's distance
     
*To try:*
  
     1. Use GloVe for vectors embedding (and recompute the similarity)
     
3.Graphical features:
  
  I have absolutely zero knowledge at that time that this kind of features can be applied into a NLP competition which turns out to be a extremely important feature (thanks to Shubhankar Srivastava's idea of pagerank feature). In the social network analysis, you can see a lot of this kind of graphical analysis as well.
  
  <img src="{{url}}/images/a.jpg" alt="pic" style="width: 400px;"/>
  
  Basically,every question is node in the graph, the degree of node here can be seen as the frequency of this question, and the common neighbors for the two node.
  
  
*To try:*

      1.maxclique features of edges
      2.maxclique features of nodes


**3. Imbalanced dataset**

  In the training dataset, since the percentage of duplicate question is 36.9%, it's important to rebalance the dataset, and there are lots of methods to deal with this problem i.e. oversample (oversample the miniority class) , undersample (undersampling the majority class). But instead of using the two sampling methods above, i used the calss weight in the xgb Dmatrix argument to let the model treat two class differently. It turned out to be quite effective, which helped me at least with 0,02 improvement.


**4. Conclusion**

add conclusion
fix type po

===
eshion
???
Really nice works, both models have been verified in various NLP tasks, such as QA, Paraphrase Identification, IR and so on~ Moreover, we have also build strong deep relevance ranking models for information retrieval, based on these excellent deep matching architectures

Liang Pang
???
As you have done, the purely MatchPyramid not work well on this dataset, if you use only dot product or cosine similarity. I suggest you use complex similarity function and combining with the MV-LSTM, it will work better.\
@faron
it turnt out the be very useful to create features based on differently pre-processed questions texts (raw, interrogative forms, stemmed, cleaned, stopwords only, stopwords removed,..) and token bags (shared & non-shared tokens)https://www.kaggle.com/c/quora-question-pairs/discussion/34359


As generally known, the book of spells has been the underlying graph structure of the question comparisons. Beside the stats like |common neighbors|, |unique neighbors|, |paths of length n between q1 & q2|, max. clique size, component size, etc. pp. we put each of our features as weights w to the edges and computed stats based on that (for instance mean(w) of common neighbors). 
We also used out-of-fold predictions as edge-weights to get something ouf of the transitive relation y(q1, q3) = a = y(q2, q3) => y(q1, q2) = a (which is inconsistent given the ground truth). Those features provided a significant gain. Last but not least, we treated strongly connected components in the graph as markov chains (state transitions could be an oof-prediction or an feature) and re-weighted given features with the estimated steady state distributions of those MCs. I don't know yet, if that added anything, but I found it interesting enough to try.


@Silogram


Congrats! I'm curious about the sparse n-gram vectors you used. The corpus is so large and I think for n-gram vector, the dimension would be far more than thousands. Did you set a cut-off to reduce the dimension to thousands?

I'm not sure about Stanislav's and Dmitry's sparse vectors, but in my case I used binary tf and set a cutoff of the top 2,000 1-grams and 2-grams. Then I summed the q1 and q2 vectors so there were three possible values for each ngram -- 0 if the ngram appeared in neither question, 1 if it appeared in only one of the questions, and 2 if it appeared in both. This turned out be a very effective strategy.
