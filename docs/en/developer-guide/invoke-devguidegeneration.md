---
online version: https://github.com/jmuelbert/jm-dev-tools
schema: 2.0.0
---

# Invoke-DevGuideGeneration

## SYNOPSIS

Comprehensive Project Analyzer and Dev Guide Generator (PowerShell version).

## SYNTAX

### Run (Default)

```powershell
Invoke-DevGuideGeneration [[-Directory] <String>] [<CommonParameters>]
```

### Version

```powershell
Invoke-DevGuideGeneration [[-Directory] <String>] [-Version] [<CommonParameters>]
```

## DESCRIPTION

Analyzes a project directory to detect technologies, configuration files, and
task runners, then generates a structured Markdown developer guide file
(DEVGUIDE.md).

## EXAMPLES

### EXAMPLE 1: Generate guide for a specific directory

This command generates the Dev Guide for the project located at C:\MyProject.

```powershell
Invoke-DevGuideGeneration -Directory C:\MyProject
```

## PARAMETERS

### -Directory

The project directory to analyze and generate the guide in. Defaults to '.'.

### -Version

Displays the version information for the Invoke-DevGuideGeneration script. This
parameter is mutually exclusive with running the generation process.

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction,
-ErrorVariable, -InformationAction, -InformationVariable, -OutVariable,
-OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

This script is intended to be run as the function 'Invoke-DevGuideGeneration'
after dot-sourcing the file to correctly integrate with documentation tools like
PlatyPS. Requires PowerShell 5.1 or later.

## RELATED LINKS

[jm-dev-tools](https://github.com/jmuelbert/jm-dev-tools)

[jm-dev-tools README](https://github.com/jmuelbert/jm-dev-tools#readme)
