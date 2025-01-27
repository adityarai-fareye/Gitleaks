#!/bin/bash

set -e

GITHUB_TOKEN="$1"
PULL_REQUEST_NUMBER="$2"
# GITHUB_EVENT="$2"

check_gitleaks_installed() {
    if command -v gitleaks >/dev/null 2>&1; then
        echo "Gitleaks is already installed."
    else
        echo "Installing Gitleaks..."
        curl -sSL https://github.com/gitleaks/gitleaks/releases/download/v8.16.1/gitleaks_8.16.1_linux_x64.tar.gz -o gitleaks.tar.gz
        tar -xzf gitleaks.tar.gz
        chmod +x gitleaks
        mv gitleaks /usr/local/bin/
        rm gitleaks.tar.gz
        echo "Gitleaks installed"
    fi
}

execute_gitleaks() {
    echo "gitleaks cmd: gitleaks detect --redact -v --exit-code=2 --log-level=debug --log-opts=--no-merges --first-parent $first_commit_sha^..$last_commit_sha"
    echo "Running Gitleaks..."
    gitleaks detect --redact -v --exit-code=2 --log-level=debug --log-opts="--no-merges --first-parent $first_commit_sha^..HEAD --"
}

REPO="${GITHUB_REPOSITORY}"
fetch_first_and_last_commit_for_pull_request() {
    echo "Repository: $REPO"
    echo "Pull Request Number: $PULL_REQUEST_NUMBER"
    echo "GitHub Token: $GITHUB_TOKEN"

    commits=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$REPO/pulls/$PULL_REQUEST_NUMBER/commits")

    echo $commits
    if echo "$commits" | jq -e '.[0]' > /dev/null 2>&1; then
        first_commit_sha=$(echo "$commits" | jq -r '.[0].sha')
        
        last_commit_sha=$(echo "$commits" | jq -r '.[-1].sha')
        
        echo "The first commit SHA is: $first_commit_sha"
        echo "The last commit SHA is: $last_commit_sha"

        echo "last_commit_sha=$first_commit_sha" >> $GITHUB_ENV
        echo "last_commit_sha=$last_commit_sha" >> $GITHUB_ENV
    else
        echo "Error: Unexpected response structure or no commits found."
        echo "$commits" | jq .
        exit 1
    fi
}

fetch_first_and_last_commit_for_pull_request
check_gitleaks_installed
execute_gitleaks





# /usr/bin/git -C . log -p -U0 --no-merges --first-parent e73a44d998131a96a95fd00b6be333ad5bb3dc09^..317573efbd862d05e4ba5c5fe6a0120c2bb89857
# /usr/bin/git -C . log -p -U0 --no-merges --first-parent b2c557f1e7b85545ad8b908bc1faf1ebd1ae0c69^..5f7f84de4642ee159fdbee872765aad67ff9a46d