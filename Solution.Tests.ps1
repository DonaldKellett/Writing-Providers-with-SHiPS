BeforeAll {
  Import-Module SHiPS
  Move-Item Solution.ps1 -Destination Solution.psm1 -Force
  Import-Module ./Solution.psm1
}

Describe "Your generalized Fibonacci provider" {
  BeforeEach {
    New-PSDrive -Name GFX -Root Solution#GenFibX -PSProvider SHiPS -WarningAction 'SilentlyContinue'
  }
  It "Defaults should be correct" {
    Get-Content GFX:\Order | Should -Be '2'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1")
    Get-Content GFX:\Seed\F_0 | Should -Be '0'
    Get-Content GFX:\Seed\F_1 | Should -Be '1'
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1")
    Get-Content GFX:\Weights\W_0 | Should -Be '1'
    Get-Content GFX:\Weights\W_1 | Should -Be '1'
    Get-Content GFX:\Start | Should -Be '0'
    Get-Content GFX:\Count | Should -Be '10'
    Get-Content GFX:\OutSeq | Should -Be '0,1,1,2,3,5,8,13,21,34'
  }
  AfterEach {
    Remove-PSDrive -Name GFX
  }
}

AfterAll {
  Remove-Module Solution
  Move-Item Solution.psm1 -Destination Solution.ps1 -Force
  Remove-Module SHiPS
}
