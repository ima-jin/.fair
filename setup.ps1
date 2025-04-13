# .fair Repository Setup Script
# This script creates or updates a .fair repository structure

# Set your GitHub organization and ensure git is logged in
$GITHUB_ORG = "ima-jin"

# Error handling function
function Write-Status {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    $color = switch ($Type) {
        "INFO" { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

# Function to safely create or update files
function Safe-WriteFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Content,
        [bool]$Force = $false
    )
    
    try {
        $fileExists = Test-Path -Path $FilePath
        
        if ($fileExists -and -not $Force) {
            Write-Status -Message "File already exists: $FilePath (Skipping)" -Type "WARNING"
            return $false
        }
        
        if ($fileExists -and $Force) {
            Write-Status -Message "Updating existing file: $FilePath" -Type "INFO"
        } else {
            Write-Status -Message "Creating new file: $FilePath" -Type "INFO"
        }
        
        $Content | Out-File -FilePath $FilePath -Encoding UTF8 -Force
        return $true
    }
    catch {
        Write-Status -Message "Failed to write file $FilePath. Error: $_" -Type "ERROR"
        return $false
    }
}

# Starting script execution
Write-Status -Message "Beginning .fair repository setup..." -Type "INFO"

# Check if we're already in a .fair directory or if we need to navigate to it
$currentDir = Split-Path -Path (Get-Location) -Leaf
if ($currentDir -ne ".fair") {
    $fairDirPath = Join-Path -Path (Get-Location) -ChildPath ".fair"
    
    if (Test-Path -Path $fairDirPath) {
        Write-Status -Message "Navigating to existing .fair directory" -Type "INFO"
        try {
            Set-Location ".fair"
        }
        catch {
            Write-Status -Message "Failed to navigate to .fair directory. Error: $_" -Type "ERROR"
            exit 1
        }
    }
    else {
        # We're not in a .fair directory and .fair doesn't exist as a subdirectory
        Write-Status -Message "Creating and navigating to .fair directory" -Type "INFO"
        try {
            New-Item -Path ".fair" -ItemType Directory -Force | Out-Null
            Set-Location ".fair"
        }
        catch {
            Write-Status -Message "Failed to create or navigate to .fair directory. Error: $_" -Type "ERROR"
            exit 1
        }
    }
}
# Create README.md
$readmeContent = @'
# .fair

> **Universal contribution metadata format.**  
> Declare who contributed, what they did, and optionally how value might be recognized.

## Why .fair?

- **Human-readable, machine-resolvable**
- **Domain-agnostic** (music, travel, software, design, events, etc.)
- Designed for **attribution, recognition, and equitable value flow**

## Quickstart

1. Clone or fork this repo
2. Write your own `.fair.json` manifest
3. Validate with our JSON schema (`schema/fair.schema.json`)
4. Plug into your system (payments, matching engines, reputation graphs, etc.)

## Examples

See `examples/` directory.

## Contributing

Open PRs or Issues. Discuss first. Philosophy matters.

## License

MIT with WLED Attribution Clause – Fully open, always.
'@

Safe-WriteFile -FilePath "README.md" -Content $readmeContent -Force $true
# Create SPEC.md placeholder
$specContent = @'
# .fair Specification v0.1

## Fields

- `id`: Unique identifier (URI recommended)
- `title`: Short, descriptive title
- `context`: Domain or general context of contribution
- `contributors`: Array of contributor objects:
  - `actor`: contributor identity (direct or reference)
  - `role`: contributor's role (open-ended)
  - `weight`: numeric (optional) contribution weight
  - `meta`: optional metadata about the contribution
- `created_by`: Identifier for manifest creator
- `created_at`: ISO timestamp
- `tags`: array of relevant tags
'@

Safe-WriteFile -FilePath "SPEC.md" -Content $specContent -Force $true
# Create directory structure and files
$directories = @("examples", "schema")
foreach ($dir in $directories) {
    if (Test-Path -Path $dir) {
        Write-Status -Message "Directory already exists: $dir" -Type "INFO"
    } else {
        try {
            New-Item -Path $dir -ItemType Directory | Out-Null
            Write-Status -Message "Created directory: $dir" -Type "SUCCESS"
        } catch {
            Write-Status -Message "Failed to create directory $dir. Error: $_" -Type "ERROR"
        }
    }
}
# Add example files
Write-Status -Message "Creating example files..." -Type "INFO"

# Event example
$eventContent = @'
{
  "id": "urn:fair:event-001",
  "title": "Cloud9 Sunset Ritual",
  "context": "Event",
  "contributors": [
    {
      "actor": { "id": "did:ethr:0xDJWallet", "name": "Seth Schwarz" },
      "role": "DJ performance",
      "weight": 0.5
    },
    {
      "actor": { "ref": "urn:fair:track-001" },
      "role": "track contributor",
      "weight": 0.5
    }
  ],
  "created_by": "did:ethr:0xRyan",
  "created_at": "2025-04-13T20:00:00Z",
  "tags": ["music", "event"]
}
'@

Safe-WriteFile -FilePath "examples/event.fair.json" -Content $eventContent -Force $true
# Open Source example
$openSourceContent = @'
{
  "id": "urn:fair:opensource-001",
  "title": "ChatGPT Extension",
  "context": "Open Source Software",
  "contributors": [
    {
      "actor": { "id": "github:imajin", "name": "Ryan Vettese" },
      "role": "maintainer",
      "weight": 0.7
    },
    {
      "actor": { "id": "github:contributor123", "name": "Contributor X" },
      "role": "code contribution",
      "weight": 0.3
    }
  ],
  "created_by": "github:imajin",
  "created_at": "2025-04-13T20:00:00Z",
  "tags": ["software", "opensource"]
}
'@

Safe-WriteFile -FilePath "examples/opensource.fair.json" -Content $openSourceContent -Force $true
# Music example
$musicContent = @'
{
  "id": "urn:fair:music-001",
  "title": "Original Track",
  "context": "Music",
  "contributors": [
    {
      "actor": { "id": "did:ethr:0xComposerWallet", "name": "Composer X" },
      "role": "composition",
      "weight": 0.6
    },
    {
      "actor": { "id": "did:ethr:0xVocalistWallet", "name": "Vocalist Y" },
      "role": "vocals",
      "weight": 0.4
    }
  ],
  "created_by": "did:ethr:0xComposerWallet",
  "created_at": "2025-04-10T10:00:00Z",
  "tags": ["music", "original"]
}
'@

Safe-WriteFile -FilePath "examples/music.fair.json" -Content $musicContent -Force $true

# Travel example
$travelContent = @'
{
  "id": "urn:fair:travel-001",
  "title": "Kensington Safari Itinerary",
  "context": "Travel",
  "contributors": [
    {
      "actor": { "id": "triparc:agent123", "name": "Travel Advisor" },
      "role": "curation",
      "weight": 0.5
    },
    {
      "actor": { "id": "triparc:supplier456", "name": "Local Guide" },
      "role": "on-the-ground delivery",
      "weight": 0.5
    }
  ],
  "created_by": "triparc:agent123",
  "created_at": "2025-03-01T09:00:00Z",
  "tags": ["travel", "kenya"]
}
'@

Safe-WriteFile -FilePath "examples/travel.fair.json" -Content $travelContent -Force $true
# Add JSON schema
Write-Status -Message "Creating JSON schema file..." -Type "INFO"
$schemaContent = @'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["id", "title", "contributors", "created_by", "created_at"],
  "properties": {
    "id": { "type": "string" },
    "title": { "type": "string" },
    "context": { "type": "string" },
    "contributors": { "type": "array" },
    "created_by": { "type": "string" },
    "created_at": { "type": "string", "format": "date-time" },
    "tags": { "type": "array" }
  }
}
'@

Safe-WriteFile -FilePath "schema/fair.schema.json" -Content $schemaContent -Force $true
# Add WLED-style MIT license
Write-Status -Message "Creating LICENSE file..." -Type "INFO"
$licenseYear = Get-Date -Format yyyy
$licenseContent = @"
MIT License with WLED attribution clause

Copyright (c) $licenseYear Imajin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included
   in all copies or substantial portions of the Software.
   
2. If you use, distribute or publish this Software, a visible attribution
   credit ("Powered by .fair") must be provided in the user interface or 
   documentation materials associated with your application or product.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"@

Safe-WriteFile -FilePath "LICENSE" -Content $licenseContent -Force $true
# Commit and push (optional)
$shouldCommit = $true  # Change to $false to skip git operations

if ($shouldCommit) {
    Write-Status -Message "Performing git operations..." -Type "INFO"
    
    # Check if git is available
    try {
        $gitVersion = git --version
        Write-Status -Message "Git detected: $gitVersion" -Type "INFO"
    }
    catch {
        Write-Status -Message "Git is not available. Skipping git operations." -Type "WARNING"
        $shouldCommit = $false
    }
    
    if ($shouldCommit) {
        try {
            # Add all files
            Write-Status -Message "Adding files to git..." -Type "INFO"
            git add .
            
            # Commit changes
            Write-Status -Message "Committing changes..." -Type "INFO"
            git commit -m "Add missing .fair example files"
            
            # Push to remote (only if the push will succeed)
            Write-Status -Message "Checking remote connection..." -Type "INFO"
            $remoteExists = $false
            try {
                $remoteCheck = git remote -v
                if ($remoteCheck -match "origin") {
                    $remoteExists = $true
                }
            }
            catch {
                Write-Status -Message "Remote 'origin' not configured." -Type "WARNING"
            }
            
            if ($remoteExists) {
                Write-Status -Message "Pushing to remote repository..." -Type "INFO"
                git push origin main
                Write-Status -Message "Repository successfully updated!" -Type "SUCCESS"
            }
            else {
                Write-Status -Message "Skipping push - remote 'origin' not configured." -Type "WARNING"
                Write-Status -Message "To push manually later, run: git push origin main" -Type "INFO"
            }
        }
        catch {
            Write-Status -Message "Git operation failed: $_" -Type "ERROR"
            Write-Status -Message "Repository setup completed but git operations failed." -Type "WARNING"
        }
    }
}
else {
    Write-Status -Message "Skipping git operations as specified." -Type "INFO"
}

Write-Status -Message ".fair repository setup completed successfully!" -Type "SUCCESS"
