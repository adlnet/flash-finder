
param (
	# Where to find the SWF to describe
    [string]$path
)

# Get the header information from this SWF file.  This will also help
# us to validate that this is indeed a proper SWF file.
$bytes = Get-Content $path -Encoding byte -TotalCount 8

# The first 3 bytes have a required order.  We'll use this for validation
$valid = $false
$compression = "Unknown"

# Convert from decimal to hex
$b0 = [String]::Format("{0:x}", $bytes[0])
$b1 = [String]::Format("{0:x}", $bytes[1])
$b2 = [String]::Format("{0:x}", $bytes[2])

# * 57 53 is the required format, so all valid SWF files will have 
# hex 57 and hex 53 as their 2nd and 3rd bytes
if ($b1 -eq "57" -and $b2 -eq "53") {

    $valid = $true
    if ($b0 -eq "43") {
        $compression = "Uncompressed"
    } 
    elseif ($b0 -eq "47") {
        $compression = "ZLIB Compression"
    } 
    elseif ($b0 -eq "60") {
        $compression = "LZMA Compression"
    } 
}

# Check if we had valid formats
if ($false -eq $valid) {
    return "0", $compression
}

# the 4th byte is its version
$version = $bytes[3]

return $version, $compression