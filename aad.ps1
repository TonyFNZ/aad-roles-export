
$Username = "fendallt@tfaadgraph.onmicrosoft.com"
$Password = ""

$ApplicationName = "Amazon Web Services (AWS)"


function Authenticate($Username, $Password) {
  $SecPass = ConvertTo-SecureString $Password -AsPlainText -Force
  $Creds = New-Object System.Management.Automation.PSCredential ($Username, $SecPass)
  $Connction = Connect-AzureAD -Credential $Creds
}


function Get-AppRoles($AppName) {
  $Application = Get-AzureADApplication -SearchString $AppName

  $HashTable = @{}
  foreach($AppRole in $Application.AppRoles) {
    $HashTable[$AppRole.Id] = $AppRole.Value;
  }

  $HashTable
}


function Get-RoleAssignments($AppName) {
  $ServicePrincipal = Get-AzureADServicePrincipal -SearchString $AppName
  $RoleAssignments = Get-AzureADServiceAppRoleAssignment -ObjectId $ServicePrincipal.ObjectId

  $RoleAssignments
}



# -----------------------------------------------------------------------------

Authenticate -Username $Username -Password $Password

$Roles = Get-AppRoles -AppName $ApplicationName

$Assignments = Get-RoleAssignments -AppName $ApplicationName

foreach($Assignment in $Assignments) {
  $Name = $Assignment.PrincipalDisplayName;
  if($Assignment.PrincipalType -eq "User") {
    $User = Get-AzureADUser -ObjectId $Assignment.PrincipalId
    $Name = $User.UserPrincipalName
  }

  $AppRole = $Roles[$Assignment.Id]

  Write-Host $Assignment.PrincipalType" "$Name" "$AppRole
}



