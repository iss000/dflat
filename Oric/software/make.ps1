# Script to build dflat file
# Source is the PC:
#   Source directory must be sd-src
#   Target directory must be dflat
# Conversion programs be in the same place as this script

# Timestamp
$startTime = (Get-Date)

# Source folder
$source = "sd-src"

# Destination folder
$destination = "dflat"

# Source folder is sd-src
Set-Location $source

# Gets a list of files and folders in the source
$files = Get-ChildItem -Recurse

# Back to root
Set-Location ../
# Clean target
Remove-Item -r ($destination+"/*")

# Initialise counters for metrics
$dircreated = 0
$binconverted = 0
$prgconverted = 0

# Process the list
Foreach ($file in $files) {

    # Only interested in relative paths after sd-src
    $relpathIdx = $file.fullname.IndexOf($source)
    $relpath = $destination + $file.fullname.Substring($relpathIdx+6)

    # If current item is a directory then check if it
    # exists in the target dflat folder, create if needed
    if ($file.attributes -eq "Directory") {
        if ((Test-Path -Path $relpath) -eq $false) {
            mkdir $relpath | Out-Null
            $dircreated++
        }
    } else {
    # If not a directory then copy across anything not a PRG
    # file, else convert PRG to TAP
        if ($file.extension -ine ".prg") {
            ../util/bin/dfbin2tap $file.fullname $relpath | Out-Null
            $prgconverted++
        } else {
            ../util/bin/dftxt2tap -l $file.fullname ($relpath.Substring(0, $relpath.Length-3)+"tap") | Out-Null
            $binconverted++
        }
    }

}
$endTime = (Get-Date)
Write-Output ("Done : "+(($endTime - $startTime).TotalSeconds)+" second(s)   Dirs:"+$dircreated+"  Prgs:"+$prgconverted+"  Bins:"+$binconverted)
