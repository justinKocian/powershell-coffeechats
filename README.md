# powershell-coffeechats
A simple dupe of Random-Coffee using Powershell. This PowerShell script is designed to organize pairs of Slack users for a bi-weekly event and post their pairings along with meeting links in a specified Slack channel. Follow these steps to set up and use the script:

## Prerequisites

1. **Slack Account and Workspace**: You must have a Slack account and access to a Slack workspace where you want to post the pairs and meeting links.

2. **Slack API Token**: Obtain a Slack API token to authenticate the script's communication with your Slack workspace. You can generate a token with appropriate permissions from the Slack API settings.

3. **CSV File**: Prepare a CSV file containing previous pairings and meeting links. The script will load this file to avoid re-pairing users who have already met.

## Setup Steps

1. **Clone Repository (Optional)**: If you plan to host this script on GitHub, create a new repository and clone it to your local machine.

2. **Edit Script Configuration**:

   Open the script file (`powershell-coffeechats.ps1`) in a text editor and modify the following configuration variables:

   - `$channelId`: Replace `"YOUR_SLACK_CHANNEL_ID"` with the actual Slack channel ID where you want to post the pairs and meeting links.
   - `$token`: Replace `"YOUR_SLACK_API_TOKEN"` with your Slack API token.
   - `$csvPath`: Replace `"C:\path\to\your\csv\file.csv"` with the actual path to your CSV file containing previous pairings and meeting links.

3. **Run the Script**:

   Open PowerShell on your computer and navigate to the directory where you saved the script.

   Run the script using the following command:

   .\powershell-coffeechats.ps1

   The script will organize user pairs and generate a message with meeting links.

4. **Configure Posting Channel**:

   In the script, locate the section where the message is prepared for posting in the Slack channel. Modify the `$channelId` variable to match the ID of the Slack channel where you want to post the message.

5. **Run the Script Again**:

   Run the script once more to post the generated message in the specified Slack channel. Use the same command as in step 3.

## Notes

- The script uses Slack's API to retrieve user information and post messages. Make sure your Slack API token has the necessary permissions.
- You can schedule the script to run automatically using task scheduling tools like Task Scheduler on Windows or cron jobs on Linux.
- To make the script public on GitHub, commit and push your changes to the repository.

Remember to handle sensitive information, like your Slack API token, securely and avoid sharing it in public repositories.
