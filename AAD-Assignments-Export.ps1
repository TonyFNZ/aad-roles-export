[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $AppObjectId
)


# Prompt the user to Authenticate to Azure AD
$Swallow = Connect-AzureAD

$ServicePrincipal = Get-AzureADServicePrincipal -ObjectId $AppObjectId

# Create a Hashtable of AppRoles so that we can get the role values later
$Roles = @{}
foreach($AppRole in $ServicePrincipal.AppRoles) {
  $Roles[$AppRole.Id] = $AppRole.Value;
}

$RoleAssignments = Get-AzureADServiceAppRoleAssignment -ObjectId $AppObjectId
$Output = @()

foreach($Assignment in $RoleAssignments) {

    $Data = @{}
    $Data.type = $Assignment.PrincipalType

    if($Assignment.PrincipalType -eq "User") {
        # Have to look up the user to get their Username rather than DisplayName
        $User = Get-AzureADUser -ObjectId $Assignment.PrincipalId
        $Data.name = $User.UserPrincipalName
    } elseif($Assignment.PrincipalType -eq "Group") {
        $Data.name = $Assignment.PrincipalDisplayName
    } else {
        Continue
    }


    $Parts = $Roles[$Assignment.Id].Split(":")
    $Data.roleARN = $Parts[0]
    if($Parts.count -gt 1) {
        $Data.idpARN = $Parts[1]
    }

    $Output += $Data
}


$Output | ConvertTo-Json | Out-File -FilePath ".\assignments.json"