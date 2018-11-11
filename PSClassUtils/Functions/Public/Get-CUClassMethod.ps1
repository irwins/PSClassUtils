Function Get-CUClassMethod {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [cmdletBinding(DefaultParameterSetName="All")]
    [OutputType([CUClassMethod[]])]
    Param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$ClassName,

        [Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        [String[]]$MethodName='*',

        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set1")]
        [CUClass[]]$InputObject,

        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,ParameterSetName="Set2",ValueFromPipelineByPropertyName=$True)]
        [System.IO.FileInfo[]]$Path,

        [Switch]$Raw
    )

    BEGIN {}

    PROCESS {

        Switch ( $PSCmdlet.ParameterSetName ) {

            ## CUClass as input
            Set1 {

                $ClassParams = @{}
                
                ## ClassName was specified
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $Class in $InputObject ) {
                    If ( $ClassParams.ClassName ) {
                        If ( $Class.Name -eq $ClassParams.ClassName ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    } Else {
                        If ( $null -ne $Class.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($Class.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $Class.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                        }
                    }
                }
            }

            ## System.io.FileInfo as Input
            Set2 {

                $ClassParams = @{}
                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }

                Foreach ( $P in $Path ) {
                    
                    If ( $P.extension -in ".ps1",".psm1" ) {

                        If ($PSCmdlet.MyInvocation.ExpectingInput) {
                            $ClassParams.Path = $P.FullName
                        } Else {
                            $ClassParams.Path = (Get-Item (Resolve-Path $P).Path).FullName
                        }
                        
                        $x=Get-CuClass @ClassParams
                        If ( $null -ne $x.Method ) {
                            If ( $PSBoundParameters['Raw'] ) {
                                
                                ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                            } Else {
                                $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                            }
                            
                        }
                    }
                }
            }

            ## System.io.FileInfo or Path Not Specified
            Default {
                $ClassParams = @{}

                If ( $null -ne $PSBoundParameters['ClassName'] ) {
                    $ClassParams.ClassName = $PSBoundParameters['ClassName']
                }
                
                Foreach( $x in (Get-CuClass @ClassParams) ){
                    If ( $x.Method.count -ne 0 ) {
                        If ( $PSBoundParameters['Raw'] ) {
                                
                            ($x.GetCUClassMethod() | Where-Object Name -like $MethodName).Raw
                        } Else {
                            $x.GetCUClassMethod() | Where-Object Name -like $MethodName
                        }
                    }
                }
                
                
            }
        }

    }

    END {}

}