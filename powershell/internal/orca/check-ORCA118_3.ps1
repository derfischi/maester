# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA118_3 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA118_3()
    {
        $this.Control="ORCA-118-3"
        $this.Area="Anti-Spam Policies"
        $this.Name="Domain Allowlist"
        $this.PassText="Your own domains are not being allow listed in an unsafe manner"
        $this.FailRecommendation="Remove allow listing on domains belonging to your organisation"
        $this.Importance="Emails coming from allow listed domains bypass several layers of protection within Exchange Online Protection. When allow listing your own domains, an attacker can spoof any account in your organisation that has this domain. This is a significant phishing attack vector."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Organisation Domain Allow Listed"
        $this.ChiValue=[ORCACHI]::Critical
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
            "Use Anti-Spam Policy Sender/Domain Allow lists"="https://aka.ms/orca-antispam-docs-4"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"] ).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $AllowedSenderDomains = @($Policy.AllowedSenderDomains)
            $PolicyName = $Config["PolicyStates"][$Policy.Guid.ToString()].Name
    
            # Fail if AllowedSenderDomains is not null
    
            If(($AllowedSenderDomains).Count -gt 0) 
            {
                ForEach($Domain in $AllowedSenderDomains) 
                {

                    # Is this domain an organisation domain?
                    If(@($Config["AcceptedDomains"] | Where-Object {$_.Name -eq $Domain}).Count -gt 0)
                    {
                        # Check objects
                        $ConfigObject = [ORCACheckConfig]::new()
                        $ConfigObject.ConfigItem=$PolicyName
                        $ConfigObject.ConfigData=$Domain
                        $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
                        $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
                        $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

                        <#
                        
                        Important! This property can be written on pre-set & default policies, do not apply read only here.

                        #>

                        $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                        $this.AddConfig($ConfigObject) 
                    } 
                }
            } else {
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.ConfigItem=$PolicyName
                $ConfigObject.ConfigData="Allowed sender domains empty"
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
                $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
                $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                $this.AddConfig($ConfigObject) 
            }
        }        
    }

}
