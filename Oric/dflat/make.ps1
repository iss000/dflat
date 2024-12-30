# Script to build dflat for Oric
try {

$start = (Get-Date)

# Build dflat LOCI ROM
Write-Output "Building LOCI ROM"
./as65 "-n" "-c" "-l" "-t" "-dBANK0" "-dDFLATLOCI" "-orom/dfloci.rom" bank/bank0.s
if ($LASTEXITCODE -gt 0) { throw }
Write-Output (Select-String -Path "bank/bank0.lst" -Pattern "mod_sz_bios_e :" -SimpleMatch).Line
Write-Output (Select-String -Path "bank/bank0.lst" -Pattern "mod_sz_language_e :" -SimpleMatch).Line

# Build dflat standard ROM
Write-Output "Building standard ROM"
./as65 "-n" "-c" "-l" "-t" "-dBANK0" "-orom/dflat.rom" bank/bank0.s
if ($LASTEXITCODE -gt 0) { throw }

#if errorlevel 1 goto errors
# copy bank\bank0.lst bank\bank0.sym

# Combine individual banks in to one 64K binary for EEPROM programming
Get-Content -Encoding Byte rom/dflat.rom, rom/dflat.rom, rom/dflat.rom, rom/dflat.rom | Set-Content -Encoding Byte rom/ORICD.ROM

# Copy bank 0 to Oricutron folder as dflat.rom
Copy-Item rom/dflat.rom -Destination ../emulator/roms/dflat.rom

# Copy tt_ and fd_ symbols to the Oricutron rom file
Set-Content -Value "tt_readbyte_setcarry = no" -Path ../emulator/roms/dflat.pch
$symbols = (Select-String -Path "bank/bank0.lst" -Pattern "tt_" -SimpleMatch).Line.TrimStart(" ")
foreach ($symbol in $symbols) {
	$items = $symbol.Split(" ")
	if ($items[0].StartsWith("tt_")) {
		Add-Content -Value ($items[0]+" = "+$items[2]) -Path ../emulator/roms/dflat.pch
	}
}
$symbols = (Select-String -Path "bank/bank0.lst" -Pattern "fd_" -SimpleMatch).Line.TrimStart(" ")
foreach ($symbol in $symbols) {
	$items = $symbol.Split(" ")
	if ($items[0].StartsWith("fd_")) {
		Add-Content -Value ($items[0]+" = "+$items[2]) -Path ../emulator/roms/dflat.pch
	}
}

Write-Output (Select-String -Path "bank/bank0.lst" -Pattern "mod_sz_bios_e :" -SimpleMatch).Line
Write-Output (Select-String -Path "bank/bank0.lst" -Pattern "mod_sz_language_e :" -SimpleMatch).Line

Write-Output ("Build completed in   :"+((Get-Date)-$start)+" seconds")

}
catch {
	Write-Output "COMPILATION ERRORS"
}

