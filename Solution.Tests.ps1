BeforeAll {
  Import-Module SHiPS
  Move-Item Solution.ps1 -Destination Solution.psm1 -Force
  Import-Module ./Solution.psm1
}

Describe "Your generalized Fibonacci provider" {
  BeforeEach {
    New-PSDrive -Name GFX -Root Solution#GenFibX -PSProvider SHiPS -WarningAction 'SilentlyContinue'
  }
  It "should support Get-Content on the appropriate items with the correct defaults" {
    Get-Content GFX:\Order | Should -Be '2'
    Get-Content GFX:\Seed\F_0 | Should -Be '0'
    Get-Content GFX:\Seed\F_1 | Should -Be '1'
    Get-Content GFX:\Weights\W_0 | Should -Be '1'
    Get-Content GFX:\Weights\W_1 | Should -Be '1'
    Get-Content GFX:\Start | Should -Be '0'
    Get-Content GFX:\Count | Should -Be '10'
    Get-Content GFX:\OutSeq | Should -Be '0,1,1,2,3,5,8,13,21,34'
  }
  It "should support Get-ChildItem on the appropriate items" {
    (Get-ChildItem GFX: | Select-Object -ExpandProperty Name) | Should -Be @("Order", "Seed", "Weights", "Start", "Count", "OutSeq")
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1")
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1")
  }
  It "should support Set-Content on the appropriate items" {
    Set-Content GFX:\Order -Value 3
    Set-Content GFX:\Seed\F_0 -Value 3
    Set-Content GFX:\Seed\F_1 -Value 1
    Set-Content GFX:\Seed\F_2 -Value 2
    Set-Content GFX:\Weights\W_0 -Value 2
    Set-Content GFX:\Weights\W_1 -Value 3
    Set-Content GFX:\Weights\W_2 -Value 0
    Set-Content GFX:\Start -Value 10
    Set-Content GFX:\Count -Value 5
    Get-Content GFX:\Order | Should -Be '3'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1", "F_2")
    Get-Content GFX:\Seed\F_0 | Should -Be '3'
    Get-Content GFX:\Seed\F_1 | Should -Be '1'
    Get-Content GFX:\Seed\F_2 | Should -Be '2'
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1", "W_2")
    Get-Content GFX:\Weights\W_0 | Should -Be '2'
    Get-Content GFX:\Weights\W_1 | Should -Be '3'
    Get-Content GFX:\Weights\W_2 | Should -Be '0'
    Get-Content GFX:\Start | Should -Be '10'
    Get-Content GFX:\Count | Should -Be '5'
    Get-Content GFX:\OutSeq | Should -Be '782,1609,3168,6391,12722'
  }
  It "should reset Seed and Weights appropriately when Order changes" {
    Set-Content GFX:\Seed\F_0 -Value 42
    Set-Content GFX:\Seed\F_1 -Value 13
    Set-Content GFX:\Weights\W_0 -Value 16
    Set-Content GFX:\Weights\W_1 -Value 29
    Set-Content GFX:\Order -Value 4
    Get-Content GFX:\Order | Should -Be 4
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1", "F_2", "F_3")
    Get-Content GFX:\Seed\F_0 | Should -Be 0
    Get-Content GFX:\Seed\F_1 | Should -Be 0
    Get-Content GFX:\Seed\F_2 | Should -Be 0
    Get-Content GFX:\Seed\F_3 | Should -Be 1
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1", "W_2", "W_3")
    Get-Content GFX:\Weights\W_0 | Should -Be 1
    Get-Content GFX:\Weights\W_1 | Should -Be 1
    Get-Content GFX:\Weights\W_2 | Should -Be 1
    Get-Content GFX:\Weights\W_3 | Should -Be 1
    Get-Content GFX:\Start | Should -Be 0
    Get-Content GFX:\Count | Should -Be 10
    Get-Content GFX:\OutSeq | Should -Be "0,0,0,1,1,2,4,8,15,29"
  }
  It "should prevent setting values less than 0 on Order, Start and Count (seed and weights can accept negative values if you wish)" {
    Set-Content GFX:\Order -Value -1 -ErrorAction 'SilentlyContinue'
    Set-Content GFX:\Start -Value -2 -ErrorAction 'SilentlyContinue'
    Set-Content GFX:\Count -Value -3 -ErrorAction 'SilentlyContinue'
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
  It "should work for empty sequences" {
    Set-Content GFX:\Count -Value 0
    Get-Content GFX:\Order | Should -Be '2'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1")
    Get-Content GFX:\Seed\F_0 | Should -Be '0'
    Get-Content GFX:\Seed\F_1 | Should -Be '1'
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1")
    Get-Content GFX:\Weights\W_0 | Should -Be '1'
    Get-Content GFX:\Weights\W_1 | Should -Be '1'
    Get-Content GFX:\Start | Should -Be '0'
    Get-Content GFX:\Count | Should -Be '0'
    Get-Content GFX:\OutSeq | Should -Be ''
  }
  It "should work for order 0 sequences" {
    Set-Content GFX:\Order -Value 0
    Get-Content GFX:\Order | Should -Be '0'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @()
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @()
    Get-Content GFX:\Start | Should -Be '0'
    Get-Content GFX:\Count | Should -Be '10'
    Get-Content GFX:\OutSeq | Should -Be '0,0,0,0,0,0,0,0,0,0'
  }
  It "should work for order 1 sequences" {
    Set-Content GFX:\Order -Value 1
    Set-Content GFX:\Seed\F_0 -Value 3
    Set-Content GFX:\Weights\W_0 -Value 2
    Get-Content GFX:\Order | Should -Be '1'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0")
    Get-Content GFX:\Seed\F_0 | Should -Be '3'
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0")
    Get-Content GFX:\Weights\W_0 | Should -Be '2'
    Get-Content GFX:\Start | Should -Be '0'
    Get-Content GFX:\Count | Should -Be '10'
    Get-Content GFX:\OutSeq | Should -Be '3,6,12,24,48,96,192,384,768,1536'
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
