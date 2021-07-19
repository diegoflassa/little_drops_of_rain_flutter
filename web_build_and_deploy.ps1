$file = ".\assets\version.properties"
if (!(Test-Path $file))
{
   New-Item -path .\assets\ -name version.properties -type "file" -value "#Sat Dec 19 20:43:08 BRT 2020
VERSION_CODE=492"
}
$versionparts = (get-content -Path $file).split('\n')
if ($versionparts -eq $null){
	New-Item -path .\assets\ -name version.properties -type "file" -value "#Sat Dec 19 20:43:08 BRT 2020
	VERSION_CODE=492"
}
$versionpartsProp = $versionparts[1].split('=')
$versionparts = $versionparts[0]
([int]$versionpartsProp[-1])++
$versionparts | set-content $file
$versionpartsProp -join('=') | add-content $file
Remove-Item .dart_tool -Recurse -Force -Confirm:$false
flutter build web --no-sound-null-safety
firebase deploy --only hosting
echo "Done!"

