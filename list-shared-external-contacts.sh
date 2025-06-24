#!/usr/bin/env bash

# OAuth 2.0 parameters
source oauth2_credentials.env

SCOPE=https://www.googleapis.com/auth/contacts
REDIRECT_URI="http://localhost"

# Step 1: Get authorization code
echo "Go to the following URL to authorize the application:"
echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=$CLIENT_ID&redirect_uri=http://localhost&response_type=code&scope=$SCOPE&access_type=offline"

# Prompt the user to enter the authorization code
echo -n "Enter the authorization code: "
read AUTHORIZATION_CODE

# Step 2: Exchange authorization code for access token
authorization_response=$(curl -s --data "code=$AUTHORIZATION_CODE&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&redirect_uri=http://localhost&grant_type=authorization_code" https://oauth2.googleapis.com/token)

# Extract access token
ACCESS_TOKEN=$(echo $authorization_response | jq -r '.access_token')

# Step 3: List contacts
XML=$(curl -X GET -H "GData-Version: 3.0" -H "Authorization: Bearer $ACCESS_TOKEN" "https://www.google.com/m8/feeds/contacts/$DOMAIN/full")
echo $XML