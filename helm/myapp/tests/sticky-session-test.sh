#!/bin/bash
     echo "Testing default routing (90% v1, 10% v2)"
     for i in {1..10}; do
       curl -H "Host: app.local" http://192.168.56.91/analyze -d '{"review": "Great food!"}' -H "Content-Type: application/json"
     done

     echo "Testing Sticky Session with x-user-id=test-user (always v2)"
     for i in {1..5}; do
       curl -H "Host: app.local" -H "x-user-id: test-user" http://192.168.56.91/analyze -d '{"review": "Great food!"}' -H "Content-Type: application/json"
     done