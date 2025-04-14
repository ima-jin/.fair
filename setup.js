#!/usr/bin/env node

/**
 * .fair Repository Setup Script
 * This script creates or updates a .fair repository structure
 */

const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const simpleGit = require('simple-git');

// Set your GitHub organization
const GITHUB_ORG = "ima-jin";

// Status logging
function logStatus(message, type = "INFO") {
  const colors = {
    INFO: chalk.cyan,
    SUCCESS: chalk.green,
    WARNING: chalk.yellow,
    ERROR: chalk.red
  };
  
  console.log(`[${colors[type](type)}] ${message}`);
}

// Function to safely create or update files
async function safeWriteFile(filePath, content, force = false) {
  try {
    const fileExists = await fs.pathExists(filePath);
    
    if (fileExists && !force) {
      logStatus(`File already exists: ${filePath} (Skipping)`, "WARNING");
      return false;
    }
    
    if (fileExists && force) {
      logStatus(`Updating existing file: ${filePath}`, "INFO");
    } else {
      logStatus(`Creating new file: ${filePath}`, "INFO");
    }
    
    await fs.outputFile(filePath, content);
    return true;
  } catch (error) {
    logStatus(`Failed to write file ${filePath}. Error: ${error.message}`, "ERROR");
    return false;
  }
}

// Main function
async function main() {
  logStatus("Beginning .fair repository setup...", "INFO");

  // Check if we're already in a .fair directory or if we need to navigate to it
  const currentDir = path.basename(process.cwd());
  if (currentDir !== ".fair") {
    const fairDirPath = path.join(process.cwd(), ".fair");
    
    if (await fs.pathExists(fairDirPath)) {
      logStatus("Navigating to existing .fair directory", "INFO");
      try {
        process.chdir(fairDirPath);
      } catch (error) {
        logStatus(`Failed to navigate to .fair directory. Error: ${error.message}`, "ERROR");
        process.exit(1);
      }
    } else {
      // We're not in a .fair directory and .fair doesn't exist as a subdirectory
      logStatus("Creating and navigating to .fair directory", "INFO");
      try {
        await fs.ensureDir(fairDirPath);
        process.chdir(fairDirPath);
      } catch (error) {
        logStatus(`Failed to create or navigate to .fair directory. Error: ${error.message}`, "ERROR");
        process.exit(1);
      }
    }
  }

  // Create README.md
  const readmeContent = `# .fair

> **Universal contribution metadata format.**  
> Declare who contributed, what they did, and optionally how value might be recognized.

## Why .fair?

- **Human-readable, machine-resolvable**
- **Domain-agnostic** (music, travel, software, design, events, etc.)
- Designed for **attribution, recognition, and equitable value flow**

## Quickstart

1. Clone or fork this repo
2. Write your own \`.fair.json\` manifest
3. Validate with our JSON schema (\`schema/fair.schema.json\`)
4. Plug into your system (payments, matching engines, reputation graphs, etc.)

## Examples

See \`examples/\` directory.

## Contributing

Open PRs or Issues. Discuss first. Philosophy matters.

## License

MIT with WLED Attribution Clause — Fully open, always.`;

  await safeWriteFile("README.md", readmeContent, true);

  // Create SPEC.md placeholder
  const specContent = `# .fair Specification v0.1

## Fields

- \`id\`: Unique identifier (URI recommended)
- \`title\`: Short, descriptive title
- \`context\`: Domain or general context of contribution
- \`contributors\`: Array of contributor objects:
  - \`actor\`: contributor identity (direct or reference)
  - \`role\`: contributor's role (open-ended)
  - \`weight\`: numeric (optional) contribution weight
  - \`meta\`: optional metadata about the contribution
- \`created_by\`: Identifier for manifest creator
- \`created_at\`: ISO timestamp
- \`tags\`: array of relevant tags`;

  await safeWriteFile("SPEC.md", specContent, true);

  // Create directory structure and files
  const directories = ["examples", "schema"];
  for (const dir of directories) {
    if (await fs.pathExists(dir)) {
      logStatus(`Directory already exists: ${dir}`, "INFO");
    } else {
      try {
        await fs.ensureDir(dir);
        logStatus(`Created directory: ${dir}`, "SUCCESS");
      } catch (error) {
        logStatus(`Failed to create directory ${dir}. Error: ${error.message}`, "ERROR");
      }
    }
  }

  // Add example files
  logStatus("Creating example files...", "INFO");

  // Event example
  const eventContent = `{
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
}`;

  await safeWriteFile("examples/event.fair.json", eventContent, true);

  // Open Source example
  const openSourceContent = `{
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
}`;

  await safeWriteFile("examples/opensource.fair.json", openSourceContent, true);

  // Music example
  const musicContent = `{
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
}`;

  await safeWriteFile("examples/music.fair.json", musicContent, true);

  // Travel example
  const travelContent = `{
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
}`;

  await safeWriteFile("examples/travel.fair.json", travelContent, true);

  // Add JSON schema
  logStatus("Creating JSON schema file...", "INFO");
  const schemaContent = `{
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
}`;

  await safeWriteFile("schema/fair.schema.json", schemaContent, true);

  // Add WLED-style MIT license
  logStatus("Creating LICENSE file...", "INFO");
  const licenseYear = new Date().getFullYear();
  const licenseContent = `MIT License with WLED attribution clause

Copyright (c) ${licenseYear} Imajin

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
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.`;

  await safeWriteFile("LICENSE", licenseContent, true);

  // Commit and push (optional)
  const shouldCommit = true;  // Change to false to skip git operations

  if (shouldCommit) {
    logStatus("Performing git operations...", "INFO");
    
    try {
      const git = simpleGit();
      
      // Check if git is available
      const gitVersion = await git.raw(['--version']);
      logStatus(`Git detected: ${gitVersion.trim()}`, "INFO");
      
      // Add all files
      logStatus("Adding files to git...", "INFO");
      await git.add('.');
      
      // Commit changes
      logStatus("Committing changes...", "INFO");
      await git.commit("Add missing .fair example files");
      
      // Push to remote (only if the push will succeed)
      logStatus("Checking remote connection...", "INFO");
      
      const remotes = await git.getRemotes(true);
      const hasOrigin = remotes.some(remote => remote.name === 'origin');
      
      if (hasOrigin) {
        logStatus("Pushing to remote repository...", "INFO");
        await git.push('origin', 'main');
        logStatus("Repository successfully updated!", "SUCCESS");
      } else {
        logStatus("Skipping push - remote 'origin' not configured.", "WARNING");
        logStatus("To push manually later, run: git push origin main", "INFO");
      }
      
    } catch (error) {
      logStatus(`Git operation failed: ${error.message}`, "ERROR");
      logStatus("Repository setup completed but git operations failed.", "WARNING");
    }
  } else {
    logStatus("Skipping git operations as specified.", "INFO");
  }

  logStatus(".fair repository setup completed successfully!", "SUCCESS");
}

// Run the script
main().catch(error => {
  logStatus(`Script execution failed: ${error.message}`, "ERROR");
  process.exit(1);
});

