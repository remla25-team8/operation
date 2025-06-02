#!/bin/bash

# Test script to generate data for the Grafana dashboard
# Usage: ./test-grafana.sh [num_requests] [host]
# Example: ./test-grafana.sh 50 dev.myapp.local

# Configurable parameters
NUM_REQUESTS=${1:-30}  # Number of requests to send (default: 30)
HOST=${2:-dev.myapp.local}  # Application host (default: dev.myapp.local)
INGRESS_IP="192.168.56.91"  # Istio Ingress IP
PORT=80  # Port (default: 80)
DELAY=0.5  # Delay between requests in seconds (default: 0.5)

# Array of positive reviews
POSITIVE_REVIEWS=(
  "This restaurant was amazing, definitely coming back!"
  "The food was delicious and the service was excellent."
  "I loved every dish we ordered, especially the dessert."
  "Great atmosphere and friendly staff, highly recommend!"
  "Best dining experience I've had in months."
  "The chef clearly knows what they're doing. Outstanding flavors!"
  "Fresh ingredients and creative dishes. Loved it!"
  "Incredible value for the quality of food you get."
  "The waitstaff was attentive without being intrusive."
  "I can't wait to bring my friends here next time!"
)

# Array of negative reviews
NEGATIVE_REVIEWS=(
  "The food was cold and the service was slow."
  "Definitely not worth the price, very disappointed."
  "The waiters were rude and the place was dirty."
  "Would not recommend this place to anyone."
  "The worst dining experience I've had in years."
  "We waited over an hour for bland, overpriced food."
  "The restaurant was too noisy and the seats uncomfortable."
  "My meal was undercooked and I got sick afterwards."
  "They got our order wrong twice. Never going back."
  "The menu was limited and the portions were tiny."
)

# Function to make a sentiment analysis request
send_analyze_request() {
  local review=$1
  echo "Sending analysis request for: \"${review:0:30}...\""
  
  curl -s -X POST "http://$INGRESS_IP:$PORT/analyze" \
    -H "Host: $HOST" \
    -H "Content-Type: application/json" \
    -d "{\"review\":\"$review\"}" > /dev/null
  
  echo "Request sent!"
}

# Function to make a feedback request
send_feedback_request() {
  local review=$1
  local prediction=$2
  local actual=$3
  
  echo "Sending feedback: prediction=$prediction, actual=$actual"
  
  curl -s -X POST "http://$INGRESS_IP:$PORT/feedback" \
    -H "Host: $HOST" \
    -H "Content-Type: application/json" \
    -d "{\"review\":\"$review\",\"prediction\":$prediction,\"actual_sentiment\":$actual}" > /dev/null
  
  echo "Feedback sent!"
}

# Initial banner
echo "====================================================="
echo "     Grafana Dashboard Test Script"
echo "====================================================="
echo "Host: $HOST:$PORT"
echo "Number of requests: $NUM_REQUESTS"
echo "Starting test..."
echo "====================================================="

# Verify that the application is reachable
echo "Verifying application is reachable..."
if curl -s -I "http://$INGRESS_IP:$PORT" -H "Host: $HOST" > /dev/null; then
  echo "Application is reachable, proceeding with test!"
else
  echo "ERROR: Cannot reach the application at http://$INGRESS_IP:$PORT (Host: $HOST)"
  echo "Verify that the application is running and the hostname is correct."
  echo "If you're using a custom hostname, make sure you've added it to your /etc/hosts file."
  exit 1
fi

# Counters
counter=0
positive_count=0
negative_count=0
correct_feedback=0
incorrect_feedback=0

# Execute analysis requests
echo "Sending $NUM_REQUESTS analysis requests..."
while [ $counter -lt $NUM_REQUESTS ]; do
  # Randomly determine whether to send a positive or negative review
  if [ $((RANDOM % 2)) -eq 0 ]; then
    # Positive review
    review_index=$((RANDOM % ${#POSITIVE_REVIEWS[@]}))
    review="${POSITIVE_REVIEWS[$review_index]}"
    send_analyze_request "$review"
    positive_count=$((positive_count + 1))
    
    # 80% chance of sending correct feedback
    if [ $((RANDOM % 10)) -lt 8 ]; then
      send_feedback_request "$review" 1 1
      correct_feedback=$((correct_feedback + 1))
    else
      send_feedback_request "$review" 1 0
      incorrect_feedback=$((incorrect_feedback + 1))
    fi
  else
    # Negative review
    review_index=$((RANDOM % ${#NEGATIVE_REVIEWS[@]}))
    review="${NEGATIVE_REVIEWS[$review_index]}"
    send_analyze_request "$review"
    negative_count=$((negative_count + 1))
    
    # 80% chance of sending correct feedback
    if [ $((RANDOM % 10)) -lt 8 ]; then
      send_feedback_request "$review" 0 0
      correct_feedback=$((correct_feedback + 1))
    else
      send_feedback_request "$review" 0 1
      incorrect_feedback=$((incorrect_feedback + 1))
    fi
  fi
  
  counter=$((counter + 1))
  echo "Progress: $counter/$NUM_REQUESTS completed"
  echo "-----------------------------------------------------"
  sleep $DELAY
done

# Summary
echo "====================================================="
echo "                   TEST COMPLETED!"
echo "====================================================="
echo "Total requests: $NUM_REQUESTS"
echo "Positive reviews: $positive_count"
echo "Negative reviews: $negative_count"
echo "Correct feedback: $correct_feedback"
echo "Incorrect feedback: $incorrect_feedback"
echo "====================================================="
echo "You can now view the data in the Grafana dashboard:"
echo "http://grafana.local"
echo "Username: admin"
echo "Password: prom-operator"
echo "====================================================="
