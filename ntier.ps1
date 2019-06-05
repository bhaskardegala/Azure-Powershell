$Group_Name = Read-Host -Prompt 'Enter Your Resource Group Name'
for ($l = 0; $l -le 1; $l++) {
    if ($Group_Name -eq "`0" ) {
        $Group_Name = Read-Host -Prompt 'Enter Your Resource Group Name again as it should not be empty'
    }
    else {
        Write-Host "Thanks for Entering Resource Group Name"
        break
    }
    if ($l -eq 0) {
        $Group_Name = "ntier"
        Write-Host "Your Group Name by default was taken as $Group_Name"
        break
    }
}
$Location = Read-Host -Prompt 'Enter Location Where You want To Create Resource'
for ($l = 0; $l -le 1; $l++) {
    if ($Location -eq "`0") {
        $Location = Read-Host -Prompt 'Enter Location agian as it should not be empty'
    }
    else {
        Write-Host "Thanks for Entering Location"
        break 
    }
    if ($l -eq 0) {
        $Location = "central us" 
        Write-Host "Your Location by default was given as $Location"
        break 
    }
} 
$Network_Name = Read-Host -Prompt 'Enter Your Vnet Name'
for ($l = 0; $l -lt 1; $l++) {
    
    if ($Network_Name -eq "`0") {
        $Network_Name = Read-Host -Prompt 'Please Re-Enter your vnet name as it should not be empty'
    }
    else {
        Write-Host "Thanks for Entering Vnet name"
        break 
    }
    if ($l -eq 0 ) {
        $Network_Name = $Group_Name 
        Write-Host "Your Vnet Name was given as $Network_Name"
        break 
    }
}
$user_name = Read-Host -Prompt 'Enter Your username for VM'
for ($l = 0; $l -le 1; $l++) {
    if ($user_name -eq "`0") {
        $user_name = Read-Host -Prompt 'Enter Your username for VM as it should not be empty'
    }
    else {
        Write-Host "Thanks for Entering username for vm"
        break
    }
    if ($l -eq 0) {
        $user_name = test 
        Write-Host "Your user_Name by default was given as $user_name"
        break 
    }
}
$user_password = Read-Host -Prompt 'Enter Your password for vm'
for ($l = 0; $l -le 1; $l++) {
    
    if ($user_password -eq "`0") {
        $user_password = Read-Host -Prompt 'Enter Your password for vm as it should not be empty'
    }
    else {
        Write-Host "Thanks for Entering password"
        break 
    }
    if ($l -eq 0) {
        $user_password = "motherINDIA@123"  
        Write-Host "Your password by default was given as $user_password"
        break 
    }
}
$i = 1
while ($i) {
    $i++
    $Test = Read-Host -Prompt 'Enter Address Range For Vnet'
    if (($Test -like "10.*.*.*/16") -or ($Test -like "192.168.*.*/16") -or ($Test -like "172.16.*.*/16")) {
        Write-Host 'Thanks For Entering Address Space'
        $Network_Workspaces = $Test
        break  
    }
    else {
        Write-Host 'Re-Enter Address Space as per cidr rules ie 10.x.x.x/16 , 192.168.x.x/16 , 172.16.x.x/16'
    }
}
while ($i) {
    $i++
    $Test1 = Read-Host -Prompt "Enter Address Range For Subnet_Web"
    if (($Test1 -like "10.*.*.*/2*") -or ($Test1 -like "192.168.*.*/2*") -or ($Test1 -like "172.16.*.*/2*")) {
        Write-Host 'Thanks For Entering Address Prefix'
        $Subnet_Prefix_Web = $Test1
        break  
    }
    else {
        Write-Host 'Re-Enter Address Prefix as per cidr rules ie 10.x.x.x/2x , 192.168.x.x/2x , 172.16.x.x/2x'
    }
}
while ($i) {
    $i++
    $Test2 = Read-Host -Prompt "Enter Address Range For Subnet_Business"
    if (($Test2 -ne $Subnet_Prefix_web) -and (($Test2 -like "10.*.*.*/2*") -or ($Test2 -like "192.168.*.*/2*") -or ($Test2 -like "172.16.*.*/2*"))) {
        Write-Host 'Thanks For Entering Address Prefix'
        $Subnet_prefix_Business = $Test2
        break  
    }
    else {
        Write-Host 'Dont Enter Same Range'
    }
}
while ($i) {
    $i++
    $Test3 = Read-Host -Prompt "Enter Address Range For Subnet_db"
    if ((($Test3 -ne $Subnet_Prefix_web) -and ($Test3 -ne $Subnet_Prefix_Business)) -and (($Test3 -like "10.*.*.*/2*") -or ($Test3 -like "192.168.*.*/2*") -or ($Test3 -like "172.16.*.*/2*"))) {
        Write-Host 'Thanks For Entering Address Prefix'
        $Subnet_prefix_db = $Test3
        break  
    }
    else {
        Write-Host 'Dont Enter Same Range'
    }
}
Write-Host "Creating Resource Group"
New-AzResourceGroup -Name $Group_Name -Location $Location
Write-Host "Created Resource group"
Write-Host "Creating web subnet"
$sub_1 = New-AzVirtualNetworkSubnetConfig -Name sub_web -AddressPrefix $Subnet_Prefix_Web
Write-Host "Created web subnet"
Write-Host "Creating business subnet"
$sub_2 = New-AzVirtualNetworkSubnetConfig -Name sub_business -AddressPrefix $Subnet_prefix_Business 
Write-Host "Created business subnet"
Write-Host "Creating db subnet"
$sub_3 = New-AzVirtualNetworkSubnetConfig -Name sub_db -AddressPrefix $Subnet_prefix_db
Write-Host "Created db subnet"
Write-Host "Creating virtual network"
New-AzVirtualNetwork -Name $Network_Name -Location $Location -ResourceGroupName $Group_Name -AddressPrefix $Network_Workspaces -Subnet $sub_1, $sub_2, $sub_3
Write-Host "Created virtual network"
Write-Host "writing security rule_1"
$userPassword = ConvertTo-SecureString -String $user_Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($user_name, $userpassword);
$x = Read-Host "how many vm's u need in each subnet"
if ($x -eq "`0") {
    $x = 1
    Write-Host "By default no of vm's in each subnet was given as 1"
}
else {
    Write-Host "you have requested to creat $x vm's in each subnet"
}
for ($w = 1; $w -le $x; $w++) {
    
    for ($n = 0; $n -le 2; $n++) {
        $rule = New-AzNetworkSecurityRuleConfig -Name "test_$n$w" -Protocol 'TCP' -SourcePortRange '*' -DestinationPortRange '*' -SourceAddressPrefix '*' -DestinationAddressPrefix '*' -Priority '1000' -Access 'Allow' -Direction 'inbound'
        Write-Host "Created security rule"
        Write-Host "Creating network security group"
        $nsg = New-AzNetworkSecurityGroup -Name "nsg_$n$w" -ResourceGroupName $Group_Name -Location $Location -SecurityRules $rule 
        Write-Host "Created network security group"
        New-AzPublicIpAddress -ResourceGroupName $Group_Name -Name "Public_$n$w" -Location $Location -AllocationMethod 'Dynamic'
        $vnet = Get-AzVirtualNetwork -Name $Network_Name -ResourceGroupName $Group_Name
        $sub_web = $vnet.Subnets[$n]
        $Get_pub_ip = Get-AzPublicIpAddress -Name "Public_$n$w" -ResourceGroupName $Group_Name 
        $ip_conf = New-AzNetworkInterfaceIpConfig -Name "nic_conf_$n$w" -Subnet $sub_web -Primary -PublicIpAddress $Get_pub_ip
        $NIC = New-AzNetworkInterface -Name "niccard_$n$w" -ResourceGroupName $Group_Name -Location $Location -IpConfiguration $ip_conf -NetworkSecurityGroup $nsg 
        $Virtualmachine = New-AzVMConfig -VMName "testing$n$w" -VMSize 'Standard_B1s' 
        $Virtualmachine = Set-AzVMOperatingSystem -VM $Virtualmachine -Linux -ComputerName "computer$n$w" -Credential $Credentials
        $Virtualmachine = Add-AzVMNetworkInterface -VM $Virtualmachine -Id $NIC.Id
        $Virtualmachine = Set-AzVMSourceImage -VM $Virtualmachine -PublisherName 'Canonical' -Offer 'UbuntuServer' -Skus '18.04-LTS' -Version 'latest' 
        New-AzVM -ResourceGroupName $Group_Name -Location $Location -VM $Virtualmachine 
    }
}

