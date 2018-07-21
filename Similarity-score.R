library('textmineR')

events_and_topics = read.csv('events_and_topics.csv', stringsAsFactors = F)
events_similarity_score = read.csv('events_similarity_score.csv', stringsAsFactors = F)
yearly_city_topics = read.csv('yearly_city_topics.csv', stringsAsFactors = F)

events_similarity_score$JSD_score = 1
events_similarity_score$Spearman_cor = 1

for (i in 1:length(events_and_topics[, 1])) {
  city = events_and_topics[i, 2]
  dist = as.numeric(events_and_topics[i, 5:19])
  mean = as.numeric(yearly_city_topics[which(yearly_city_topics$city == city), 2:16])
  events_similarity_score$JSD_score[i] = CalcJSDivergence(dist, mean)
  events_similarity_score$Spearman_cor[i] = cor(dist, mean, method = 'spearman')
}
write.csv(events_similarity_score, 'event_similarity_score.csv')
