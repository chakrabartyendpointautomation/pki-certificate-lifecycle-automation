[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [Parameter()]
    [ValidateRange(1, 365)]
    [int]$RenewWithinDays = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredColumns = @(
    'AssetAlias',
    'CertificateType',
    'OwnerTeam',
    'Environment',
    'NotAfterUtc'
)

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Input CSV not found: $Path"
}

$rows = @(Import-Csv -LiteralPath $Path)
if ($rows.Count -eq 0) {
    throw 'Input CSV contains no data rows.'
}

$actualColumns = @($rows[0].PSObject.Properties.Name)
$missingColumns = @($requiredColumns | Where-Object { $_ -notin $actualColumns })
if ($missingColumns.Count -gt 0) {
    throw "Input CSV is missing required columns: $($missingColumns -join ', ')"
}

$seenAliases = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$results = foreach ($row in $rows) {
    $alias = ([string]$row.AssetAlias).Trim()
    if ([string]::IsNullOrWhiteSpace($alias)) {
        throw 'Input contains a blank AssetAlias.'
    }
    if (-not $seenAliases.Add($alias)) {
        throw "Input contains a duplicate AssetAlias: $alias"
    }

    $expiryText = ([string]$row.NotAfterUtc).Trim()
    $expiry = [DateTimeOffset]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    $parsed = [DateTimeOffset]::TryParse(
        $expiryText,
        [System.Globalization.CultureInfo]::InvariantCulture,
        $styles,
        [ref]$expiry
    )
    if (-not $parsed) {
        throw "Invalid NotAfterUtc value for alias '$alias'. Use an ISO 8601 UTC timestamp."
    }

    $daysRemaining = [int][Math]::Ceiling(($expiry.UtcDateTime - [DateTime]::UtcNow).TotalDays)
    $status = if ($daysRemaining -le 0) {
        'Expired'
    } elseif ($daysRemaining -le $RenewWithinDays) {
        'RenewalDue'
    } else {
        'Current'
    }

    [pscustomobject]@{
        AssetAlias      = $alias
        CertificateType = [string]$row.CertificateType
        OwnerTeam       = [string]$row.OwnerTeam
        Environment     = [string]$row.Environment
        NotAfterUtc     = $expiry.UtcDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ', [System.Globalization.CultureInfo]::InvariantCulture)
        DaysRemaining   = $daysRemaining
        LifecycleStatus = $status
    }
}

$results | Sort-Object DaysRemaining, AssetAlias
