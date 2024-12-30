# Script to build dflat utilities
try {

$start = (Get-Date)
    
# Build cpp utilities - put them all in one bin folder
gcc ./dfbin2tap/dfbin2tap.cpp -o ./bin/dfbin2tap
if ($LASTEXITCODE -gt 0) { throw }
gcc ./dftap2txt/dftap2txt.cpp -o ./bin/dftap2txt
if ($LASTEXITCODE -gt 0) { throw }
gcc ./dftap2wav/dftap2wav.cpp -o ./bin/dftap2wav
if ($LASTEXITCODE -gt 0) { throw }
gcc ./dftxt2tap/dftxt2tap.cpp -o ./bin/dftxt2tap
if ($LASTEXITCODE -gt 0) { throw }

Write-Output ("Build completed in   :"+((Get-Date)-$start)+" seconds")

} catch {
	Write-Output "COMPILATION ERRORS"
}