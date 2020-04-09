Connect-AzureAD
$output = @()
$splist = Get-AzureADServicePrincipal -all $true


foreach ($sp in $splist)
{
    $appRoles = @{ "$([Guid]::Empty.ToString())" = "(default)" }
    $sp.AppRoles | % { $appRoles[$_.Id] = $_.DisplayName }

    $itemlist = Get-AzureADServiceAppRoleAssignment -ObjectId $sp.objectId
    if($itemlist)
    {
        foreach($item in $itemlist)
        {
            if($item.PrincipalType -ne "ServicePrincipal")
            {
                $id = $item.PrincipalId
                $data = New-Object -TypeName psobject
                $data | Add-Member -MemberType NoteProperty -Name 'Application' -Value $item.ResourceDisplayName
                $data | Add-Member -MemberType NoteProperty -Name 'value' -Value $item.ID
                $data | Add-Member -MemberType NoteProperty -Name 'Type' -Value $item.PrincipalType
                $data | Add-Member -MemberType NoteProperty -Name 'AppRole' -Value $appRoles[$item.Id]

                if($item.PrincipalType -eq "User") 
                {
                     #user assignment
                     $user = Get-AzureADUser -objectId $id
                     $data | Add-Member -MemberType NoteProperty -Name 'Username' -Value $user.UserPrincipalName
                     $data | Add-Member -MemberType NoteProperty -Name 'Firstname' -Value $user.GivenName
                     $data | Add-Member -MemberType NoteProperty -Name 'Lastname' -Value $user.Surname
                     $data | Add-Member -MemberType NoteProperty -Name 'Displayname' -Value $user.DisplayName
                     $data | Add-Member -MemberType NoteProperty -Name 'Groupname' -Value " "

                }else
                {
                    #group assignment
                    $data | Add-Member -MemberType NoteProperty -Name 'Groupname' -Value $item.PrincipalDisplayName
                }

                $output += $data
            
            }
        }
    }
}
$output | Export-Csv -NoTypeInformation -Path D:\users_assignement1.csv