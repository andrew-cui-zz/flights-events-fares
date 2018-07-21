# Author: Olivier Grisel <olivier.grisel@ensta.org>
#         Lars Buitinck
#         Chyi-Kwei Yau <chyikwei.yau@gmail.com>
#         adapted by Yutong Liu
# License: BSD 3 clause

import string
from nltk.corpus import stopwords 
from nltk.stem.wordnet import WordNetLemmatizer
import pandas as pd
import numpy as np
from __future__ import print_function
from time import time
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.decomposition import LatentDirichletAllocation
import os
print(os.getcwd())

%matplotlib inline

events_US = pd.read_csv('events_US.csv', encoding = 'latin-1')
events_US.head()

events = list(events_US['event_name'])

stop = set(stopwords.words('english'))
exclude = set(string.punctuation).union(set(string.digits))
lemma = WordNetLemmatizer()

def clean(doc):
    stop_free = " ".join([i for i in doc.lower().split() if i not in stop])
    punc_numb_free = ''.join(ch for ch in stop_free if ch not in exclude)
    normalized = " ".join(lemma.lemmatize(word) for word in punc_numb_free.split())
    return normalized

events_clean = [clean(event).split() for event in events]
events_clean[:3]

events_clean = [" ".join(x) for x in events_clean]
events_clean[0]

print("Extracting tf features for LDA...")
n_features = 1000

tf_vectorizer = CountVectorizer(max_df=0.95, min_df=2,
                                max_features=n_features,
                                stop_words='english')
t0 = time()
tf = tf_vectorizer.fit_transform(events_clean)
print("done in %0.3fs." % (time() - t0))
print()

lda_15 = LatentDirichletAllocation(n_components=15, max_iter=50,
                                learning_method='online',
                                learning_offset=50.,
                                random_state=0,
                                n_jobs=-1) # n_jobs=-1 to use multicoreprocessing
t0 = time()
lda_15.fit(tf)
print("done in %0.3fs." % (time() - t0))

print("\nTopics in LDA model:")
tf_feature_names = tf_vectorizer.get_feature_names()

n_top_words = 15
print_top_words(lda_15, tf_feature_names, n_top_words)

topic_assns = lda_15.transform(tf)
events_and_topics = pd.concat([events_US.reset_index(), pd.DataFrame(topic_assns)], axis=1)
events_and_topics.head()

events_and_topics.drop(events_and_topics.columns[0], axis = 1, inplace = True)
events_and_topics.head()

month = []
day = []
year = []

for index, row in events_and_topics.iterrows():
    day.append(row['date'].split('/')[0])
    month.append(row['date'].split('/')[1])
    year.append(row['date'].split('/')[2])
    
events_and_topics['month'] = month
events_and_topics['day'] = day
events_and_topics['year'] = year
events_and_topics.head()

monthly_city_topics = events_and_topics.groupby(['city', 'month'], as_index = False).mean()
monthly_city_topics.head()

yearly_city_topics = monthly_city_topics.groupby(['city'], as_index = False).mean()
yearly_city_topics.head()



