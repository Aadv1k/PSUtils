<#
.SYNOPSIS
    Get-RedditImage download/mine images including galleries provided a piped JSON string or a FilePath 

.PARAMETER FilePath
    Specifies the path to the JSON file containing Reddit data. This parameter is optional.

.PARAMETER OutDir
    Specifies the directory where downloaded images will be saved. This parameter is optional. If not provided, images will be saved to a directory named "data" in the current location.
#>

param (
    [string]$FilePath,
    [string]$OutDir = ".\data"
)

$Prefix = "[RedditImageMiner]"
$RawData = ""

if ($input) {
  $RawData = $input -join "`n"
} elseif ($args.Length -gt 0) {
    $FilePath = $args[0]

    if (-not $FilePath -or -not (Test-Path $FilePath)) {
        Write-Error "$Prefix A valid file path was expected as the first argument, got $FilePath" -ErrorAction Stop
        exit 1
    }

    $RawData = Get-Content -Path $FilePath -ErrorAction Stop
} else {
    Write-Error "$Prefix Expected raw text data to be either piped-into or a file to be provided, found none."
    exit 1
}

New-Item -Name $OutDir -ItemType "directory" -Force > $null

try {
    $FileData = $RawData | ConvertFrom-Json
} catch {
    Write-Error "$Prefix Unable to read or parse the JSON data: $_" -ErrorAction Stop
    exit 1
}


$FileData.data.children | ForEach-Object {
    $Data = $_.data
    $IsGallery = $Data.is_gallery -eq $true

    if ($IsGallery) {
        $ParentDirectory = "$OutDir\$($Data.name)"

        if (!(Test-Path -Path $ParentDirectory -PathType Container)) {
            mkdir $ParentDirectory -ErrorAction Continue > $null
        }

        foreach ($GalleryObject in $Data.gallery_data.items) {
            $MediaID = $GalleryObject.media_id
            $MimeType = ($Data.media_metadata.$MediaID.m -match "image\/(.*)") -replace "image\/"
            $Extension = $Matches[1]

            $ImageFileName = "$MediaID.$Extension"
            $ImageURL = "https://i.redd.it/$ImageFileName"
            $ImageFilePath = "$ParentDirectory\$ImageFileName"

            Invoke-WebRequest -Uri $ImageURL -OutFile $ImageFilePath
        }
    } else {
        $ImageURL = $Data.url_overridden_by_dest
        $IsFileURL = $Data.url_overridden_by_dest -match "[^/]+$"
        $ImageFilePath = "$OutDir\" + $Matches[0]

        # Make sure only URLs ending with an extension end up here
        if ($ImageURL -match "\.[a-zA-Z0-9]+$") {
            Invoke-WebRequest -Uri $ImageURL -OutFile $ImageFilePath
        } else {
            Write-Warning "$Prefix Skipping URL: $ImageURL" 
        }
    }
}
