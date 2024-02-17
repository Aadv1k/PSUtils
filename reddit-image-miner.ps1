$File = $args[0]
$OutputDir = $args[1]

if (-not $File -or -not (Test-Path $File)) {
    Write-Error "[ERROR] Please provide a valid JSON file path." -ErrorAction Stop
    exit 1
}

if (-not $OutputDir) {
    Write-Error "[ERROR] Please provide an output directory path." -ErrorAction Stop
    exit 1
}

if (-not (Test-Path $OutputDir)) {
    try {
        mkdir $OutputDir -ErrorAction Stop
    }
    catch {
        Write-Error "[ERROR] Unable to create the output directory: $_" -ErrorAction Stop
        exit 1
    }
}

try {
    $FileContent = Get-Content -Path $File -ErrorAction Stop
    $FileData = $FileContent | ConvertFrom-Json
}
catch {
    Write-Error "[ERROR] Unable to read or parse the JSON file: $_" -ErrorAction Stop
    exit 1
}

$FileData.data.children | ForEach-Object {  
    $Data = $_.data
    $IsGallery = ($Data.is_gallery ?? $false)

    if ( $IsGallery ) {
        $ParentDirectory = "$OutputDir\$($Data.name)"

        mkdir $ParentDirectory -ErrorAction Continue

        ForEach ($GalleryObject in $Data.gallery_data.items) {
            $MediaID = $GalleryObject.media_id
            $MimeType = $Data.media_metadata."$MediaID".m -match "image\/(.*)"
            $Extension = $Matches[1]

            $ImageFileName = "$MediaID.$Extension"
            $ImageURL = "https://i.redd.it/$ImageFileName"
            $ImageFilePath = "$ParentDirectory\$ImageFileName"

            Invoke-WebRequest $ImageURL -OutFile $ImageFilePath
        }
    } else {
        $ImageURL = $Data.url_overridden_by_dest
        $IsFileURL = $Data.url_overridden_by_dest -match "[^/]+$"
        $ImageFilePath = "$OutputDir\$($Matches[0])"

        # Make sure only URLs ending with an extension end up here
        if ( $ImageURL -match "\.[a-zA-Z0-9]+$" ) { 
            Invoke-WebRequest $ImageURL -OutFile $ImageFilePath
        } 
        else { }
    }
}
