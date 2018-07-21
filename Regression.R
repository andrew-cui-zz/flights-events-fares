quarterly_events_similarity_score <- read.csv('monthly_events_similarity_score.csv', stringsAsFactors = F)

for (i in 1:length(quarterly_events_similarity_score[, 1])) {
  if (quarterly_events_similarity_score$month[i] <= 3) {
    quarterly_events_similarity_score$quarter[i] <- 1
  } else if (quarterly_events_similarity_score$month[i] <= 6) {
    quarterly_events_similarity_score$quarter[i] <- 2
  } else if (quarterly_events_similarity_score$month[i] <= 9) {
    quarterly_events_similarity_score$quarter[i] <- 3
  } else {
    quarterly_events_similarity_score$quarter[i] <- 4
  }
}
quarterly_events_similarity_score <- quarterly_events_similarity_score[, c(5, 2, 3, 4)]

fares_full_data <- read.csv('fares_full_data.csv', stringsAsFactors = F)

new_fares_full_data <- data.frame(d_city = fares_full_data$destination_city, o_city = fares_full_data$origin_city, quarter = fares_full_data$quarter, mean = fares_full_data$mean, sd = fares_full_data$sd, distance = fares_full_data$distance, airline_id = fares_full_data$airline_id)
new_fares_full_data$o_spearman <- 0
new_fares_full_data$d_spearman <- 0
new_fares_full_data$o_JSD <- 0
new_fares_full_data$d_JSD <-0


for (i in 1:length(new_fares_full_data[, 1])) {
  o_city <- new_fares_full_data$o_city[i]
  d_city <- new_fares_full_data$d_city[i]
  quarter <- new_fares_full_data$quarter[i]
  quarter_city <- quarterly_events_similarity_score[which(quarterly_events_similarity_score$quarter == quarter), ]
  if (o_city %in% quarter_city$city) {
    new_fares_full_data$o_spearman[i] <- quarterly_events_similarity_score[which(quarterly_events_similarity_score$quarter == quarter & quarterly_events_similarity_score$city == o_city), ]$Spearman_cor
    new_fares_full_data$o_JSD[i] <- quarterly_events_similarity_score[which(quarterly_events_similarity_score$quarter == quarter & quarterly_events_similarity_score$city == o_city), ]$JSD_score
  }
  if (d_city %in% quarter_city$city) {
    new_fares_full_data$d_spearman[i] <- quarterly_events_similarity_score[which(quarterly_events_similarity_score$quarter == quarter & quarterly_events_similarity_score$city == d_city), ]$Spearman_cor
    new_fares_full_data$d_JSD[i] <- quarterly_events_similarity_score[which(quarterly_events_similarity_score$quarter == quarter & quarterly_events_similarity_score$city == d_city ), ]$JSD_score
  }
}

o_data <- new_fares_full_data[which(new_fares_full_data$o_spearman != 0), ]
d_data <- new_fares_full_data[which(new_fares_full_data$d_spearman != 0), ]

model_1 <- lm(dist_fare ~ o_spearman + quarter, data = o_data)
summary(model_3)

tidy_1 <- tidy(model_1)
write.csv(tidy_1, 'tidy_1.csv')

model_2 <- lm(dist_fare ~ o_JSD  + quarter, data = o_data)
summary(model_2)

tidy_2 <- tidy(model_2)
write.csv(tidy_2, 'tidy_2.csv')


model_3 <- lm(dist_fare ~ d_spearman + quarter, data = d_data)
summary(model_3)
tidy_3 <- tidy(model_3)
write.csv(tidy_3, 'tidy_3.csv')

model_4 <- lm(dist_fare ~ d_JSD  + quarter, data = d_data)
summary(model_4)
tidy_4 <- tidy(model_4)
write.csv(tidy_4, 'tidy_4.csv')

