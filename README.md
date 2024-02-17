# PSUtils

A collection of powershell scripts that could be helpful in many ways.

> **NOTE**
> This is a way for me to learn more about powershell, hence development is iterative and may break things. Thanks for checking this out!

## [Get-RedditImage](./Get-RedditImage.ps1)

Utility to download images from reddit JSON data, with support for galleries.

```powershell
curl 
    -A "MyRedditScraper/1.0" 
    "https://www.reddit.com/r/wallpapers.json?limit=2" | .\Get-RedditImage.ps1 -OutDir "wallpapers"
```

Alternatively, provide an input file

```powershell
.\Get-RedditImage.ps1 .\input.json -OutDir "example"
```
