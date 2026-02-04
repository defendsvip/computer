\
# Sets Windows display/UI language and locale defaults to Simplified Chinese (zh-CN).
# Designed for GitHub Actions Windows runners (non-persistent). Applies to new logons; a reboot/sign-out
# may be required for every surface to reflect changes.

$ErrorActionPreference = "Stop"

Write-Host "==> Installing zh-CN language capabilities (best-effort)..."

# Some runners already have language bits; Add-WindowsCapability is idempotent.
$capabilities = @(
  "Language.Basic~~~zh-CN~0.0.1.0",
  "Language.Handwriting~~~zh-CN~0.0.1.0",
  "Language.OCR~~~zh-CN~0.0.1.0",
  "Language.Speech~~~zh-CN~0.0.1.0",
  "Language.TextToSpeech~~~zh-CN~0.0.1.0"
)

foreach ($cap in $capabilities) {
  try {
    $state = (Get-WindowsCapability -Online -Name $cap).State
    if ($state -ne "Installed") {
      Write-Host "    Installing capability: $cap"
      Add-WindowsCapability -Online -Name $cap | Out-Null
    } else {
      Write-Host "    Already installed: $cap"
    }
  } catch {
    Write-Warning "    Skipped $cap (capability may be unavailable on this image): $($_.Exception.Message)"
  }
}

Write-Host "==> Setting UI language, user language list, locale, and region to zh-CN..."

try { Set-WinUILanguageOverride -Language "zh-CN" } catch { Write-Warning "Set-WinUILanguageOverride failed: $($_.Exception.Message)" }
try {
  $list = New-WinUserLanguageList -Language "zh-CN"
  # Keep English as fallback (helps if some resources are missing)
  $list.Add("en-US") | Out-Null
  Set-WinUserLanguageList -LanguageList $list -Force
} catch { Write-Warning "Set-WinUserLanguageList failed: $($_.Exception.Message)" }

try { Set-WinSystemLocale -SystemLocale "zh-CN" } catch { Write-Warning "Set-WinSystemLocale failed: $($_.Exception.Message)" }
try { Set-Culture -CultureInfo "zh-CN" } catch { Write-Warning "Set-Culture failed: $($_.Exception.Message)" }
try { Set-WinHomeLocation -GeoId 45 } catch { Write-Warning "Set-WinHomeLocation failed: $($_.Exception.Message)" } # 45 = China
try { Set-WinDefaultInputMethodOverride -InputTip "0804:00000804" } catch { Write-Warning "Set-WinDefaultInputMethodOverride failed: $($_.Exception.Message)" } # zh-CN IME

Write-Host "==> Copying user international settings to system (Welcome screen + new users)..."
try {
  Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
} catch {
  Write-Warning "Copy-UserInternationalSettingsToSystem failed: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Done. New logon sessions should prefer zh-CN UI. For full effect everywhere, a reboot/sign-out may be required."
