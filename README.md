# PSUtils

A collection of powershell scripts that could be helpful in many ways.

> **NOTE**
> This is a way for me to learn more about powershell, hence development is iterative and may break things. Thanks for checking this out!

## [Get-RedditImage](./Get-RedditImage.ps1)

```powershell
Get-Help .\Get-RedditImage.ps1 -Detailed
```

```powershell
NAME
    A:\PSUtils\Get-RedditImage.ps1
    
SYNOPSIS
    A script to images (including galleries) given (sub)reddit JSON data. 
    See: https://www.reddit.com/dev/api/

SYNTAX
    A:\PSUtils\Get-RedditImage.ps1 [[-FilePath] <String>] [[-OutDir] <String>] [<CommonParameters>]

PARAMETERS
    -FilePath <String>
        Specifies the path to the JSON file containing Reddit data. This parameter is optional.
        
    -OutDir <String>
        Specifies the directory where downloaded images will be saved. This parameter is optional. If not provided, images will be saved to a directory named "data" in the current location.
        
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Invoke-WebRequest "https://reddit.com/r/wallpapers/top.json?limit=5" | Get-RedditImage -OutDir wallpapers
    j
    Get top 5 wallpapers from r/wallpapers
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Get-RedditImage -FilePath .\data.json -OutDir dataisbeautiful
    
    Get newest visualizations from r/dataisbeautiful
```
