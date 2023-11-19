#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to check if a user is a repository collaborator
function check_collaborator {
    local repo_owner="$1"
    local repo_name="$2"
    local collaborator_username="$3"
    local endpoint="repos/${repo_owner}/${repo_name}/collaborators/${collaborator_username}"

    # Send a GET request to check collaborator status
    response=$(github_api_get "$endpoint")

    if [[ "$response" == "" ]]; then
        echo "$collaborator_username is not a collaborator of ${repo_owner}/${repo_name}."
    else
        echo "$collaborator_username is a collaborator of ${repo_owner}/${repo_name}."
    fi
}

# Function to remove a repository collaborator
function remove_collaborator {
    local repo_owner="$1"
    local repo_name="$2"
    local collaborator_username="$3"
    local endpoint="repos/${repo_owner}/${repo_name}/collaborators/${collaborator_username}"

    # Send a DELETE request to remove the collaborator
    response=$(curl -s -X DELETE \
                    -H "Accept: application/vnd.github.v3+json" \
                    -H "Authorization: Bearer $TOKEN" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    -o /dev/null -w "%{http_code}" \
                    "${API_URL}/${endpoint}")
    if [[ $response -eq 204 ]]; then
        echo "$collaborator_username has been successfully removed as a collaborator from ${repo_owner}/${repo_name}."
    elif [[ $response -eq 404 ]]; then
        echo "$collaborator_username is not a collaborator of ${repo_owner}/${repo_name}."
    else
        echo "Failed to remove collaborator. HTTP response code: $response"
    fi
}

# Main script
if [[ "$4" == "remove" ]]; then
    echo "Removing $3 as a collaborator from $1/$2..."
    remove_collaborator "$1" "$2" "$3"
elif [[ "$4" == "check" ]]; then
    echo "Checking if $3 is a collaborator of $1/$2..."
    check_collaborator "$1" "$2" "$3"
else
    echo "Invalid argument. Please specify 'check' or 'remove' as an argument."
fi
