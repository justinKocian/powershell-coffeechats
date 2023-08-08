# This PowerShell script is used for organizing and posting pairs of Slack users for a bi-weekly event, along with their respective meeting links.

# Configuration
$channelId = "[YOUR_CHANNEL_ID]" # Specify the Slack channel ID where the pairs will be posted
$token = "[YOUR_SLACK_TOKEN" # Slack API token for authentication
$headers = @{
    "Authorization" = "Bearer $token"
}
$csvPath = "[YOUR_CSV_PATH]" # Path to the CSV file containing previous pairings and meeting links

# Initialize an array to store user pairs and related information
[array]$psPairs = @()

# Load previous pairings and meeting links from the CSV file
$priorCSV = Import-CSV $csvPath -Delimiter ","

# Retrieve member IDs from the Slack channel
$url = "https://slack.com/api/conversations.members?channel=$channelId&pretty=1"
$memberIDList = (Invoke-RestMethod -Method GET -URI $url -Headers $headers).members

# Retrieve user information and create a list of non-bot users
[System.Collections.ArrayList]$userList = @()
forEach ($member in $memberIDList) {
    $url = "https://slack.com/api/users.info?user=$member&pretty=1"
    $user = (Invoke-RestMethod -Method GET -URI $url -Headers $headers).user
    If ($user.is_bot -eq $false) {
        $userList += [psCustomObject]@{
            Name = $($user.name)
            ID   = $($user.id)
        }
    }
}

# Pairing Logic
$i = 0
$a = 1
$uc = $userList.count

# Loop to create pairs
Do {
    Do {
        $tryAgain = $false
        
        # Randomly select two users for pairing
        if ($userList.count -ne 3) {
            $aNum = Get-Random -Minimum 0 -Maximum $userList.count
            $aUser = $userList[$aNum].Name
            $aID = $userList[$aNum].ID
            Do {
                $bNum = Get-Random -Minimum 0 -Maximum $userList.count
            }Until($bNum -ne $aNum)
            $bUser = $userList[$bNum].Name
            $bID = $userList[$bNum].ID
        
            # Compare if the selected users met last time
            $compA = ($priorCSV | Where { $_.Pair1 -eq $aUser -or $_.Pair2 -eq $aUser -or $_.Pair3 -eq $aUser })
            $compB = ($priorCSV | Where { $_.Pair1 -eq $bUser -or $_.Pair2 -eq $bUser -or $_.Pair3 -eq $bUser })
            
            # If they haven't met before, create a pair
            if ($compA.ID -ne $compB.ID) {
                $userList.Remove($($userList | Where Name -eq $aUser))
                $userList.Remove($($userList | Where Name -eq $bUser))
                $psPairs += [PSCustomObject]@{
                    ID          = $a
                    Pair1       = $aUser
                    Pair1ID     = $aID
                    Pair2       = $bUser
                    Pair2ID     = $bID
                    Pair3       = ""
                    Pair3ID     = ""
                    MeetingLink = $(($priorCSV | Where ID -eq $a).MeetingLink)
                }
                $i = $i + 2
            }
            else {
                $tryAgain = $true
            }
        }
        else {
            # If only three users are left, create a group of three
            $psPairs += [PSCustomObject]@{
                ID          = $a
                Pair1       = $userList[0].Name
                Pair1ID     = $userList[0].ID
                Pair2       = $userList[1].Name
                Pair2ID     = $userList[1].ID
                Pair3       = $userList[2].Name
                Pair3ID     = $userList[2].ID
                MeetingLink = $(($priorCSV | Where ID -eq $a).MeetingLink)
            }
            $i = $i + 3
        }
    }While ($tryAgain -eq $true)
    $a++
}Until($uc -le $i)

# Save the pairs for next time
$psPairs | Export-CSV $csvPath -NoTypeInformation -Force

# Generate message content for posting in the Slack channel
$body = "*Bi-Weekly Get to know ya's*`n"
ForEach ($r in $psPairs) {
    if ($r.Pair3ID -eq "") {
        $body += "<@$($r.Pair1ID)> :coffee: <@$($r.Pair2ID)> :meeting: $($r.MeetingLink)`n"
    }
    else {
        $body += "<@$($r.Pair1ID)> :coffee: <@$($r.Pair2ID)> :coffee: <@$($r.Pair3ID)> :meeting: $($r.MeetingLink)`n"
    }
}

# Post the message in the Slack channel
$channelId = "[YOUR_CHANNEL_ID" # Specify the channel where the message will be posted

$url = "https://slack.com/api/chat.postMessage?channel=$channelId&icon_emoji=%3Acoffee%3A&text=$body&username=CoffeeBot&pretty=1"
Invoke-RestMethod -Method POST -URI $url -Headers $headers
