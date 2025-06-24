#!/usr/bin/env bash

# OAuth 2.0 parameters
source oauth2_credentials.env

SCOPE=https://www.googleapis.com/auth/contacts

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

# Step 3: Ask user for the name, email address, phone number, role and company of the new contact
echo -n "First name: "
read FIRST_NAME

echo -n "Last name: "
read LAST_NAME

echo -n "Primary email address: "
read PRIMARY_EMAIL_ADDRESS

echo -n "Phone number: "
read PHONE_NUMBER

echo -n "Company: "
read COMPANY

echo -n "Role: "
read ROLE

# Step 4: Create contact
response=$(curl -s -H "Content-Type: application/atom+xml" -H "GData-Version: 3.0" -H "Authorization: Bearer $ACCESS_TOKEN" -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<atom:entry xmlns:atom=\"http://www.w3.org/2005/Atom\"
    xmlns:gd=\"http://schemas.google.com/g/2005\">
  <atom:category scheme=\"http://schemas.google.com/g/2005#kind\"
    term=\"http://schemas.google.com/contact/2008#contact\" />
  <gd:name>
    <gd:givenName>$FIRST_NAME</gd:givenName>
    <gd:familyName>$LAST_NAME</gd:familyName>
    <gd:fullName>$FIRST_NAME $LAST_NAME</gd:fullName>
  </gd:name>
  <gd:email rel=\"http://schemas.google.com/g/2005#work\"
    primary=\"true\"
    address=\"$PRIMARY_EMAIL_ADDRESS\" displayName=\"$FIRST_NAME $LAST_NAME\" />
  <gd:organization>
    <gd:orgName>$COMPANY</gd:orgName>
    <gd:orgTitle>$ROLE</gd:orgTitle>
  </gd:organization>
</atom:entry>" "https://www.google.com/m8/feeds/contacts/$DOMAIN/full")

# Print the response
echo "Response: $response"