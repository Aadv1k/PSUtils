$Prefix = "[RedditImageMiner]"
$OutputDir = $args[1] ?? ".\data" 

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

New-Item -Name $OutputDir -ItemType "directory" -Force > $null

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
        $ParentDirectory = "$OutputDir\$($Data.name)"

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
        $ImageFilePath = "$OutputDir\" + $Matches[0]

        # Make sure only URLs ending with an extension end up here
        if ($ImageURL -match "\.[a-zA-Z0-9]+$") {
            Invoke-WebRequest -Uri $ImageURL -OutFile $ImageFilePath
        } else {
            Write-Warning "$Prefix Skipping URL: $ImageURL" 
        }
    }
}
