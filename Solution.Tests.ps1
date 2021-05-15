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
  It "should handle huge terms with arbitrary precision" {
    Set-Content GFX:\Order -Value 4
    Set-Content GFX:\Start -Value 1000
    Set-Content GFX:\Count -Value 10
    Get-Content GFX:\Order | Should -Be '4'
    (Get-ChildItem GFX:\Seed | Select-Object -ExpandProperty Name) | Should -Be @("F_0", "F_1", "F_2", "F_3")
    Get-Content GFX:\Seed\F_0 | Should -Be '0'
    Get-Content GFX:\Seed\F_1 | Should -Be '0'
    Get-Content GFX:\Seed\F_2 | Should -Be '0'
    Get-Content GFX:\Seed\F_3 | Should -Be '1'
    (Get-ChildItem GFX:\Weights | Select-Object -ExpandProperty Name) | Should -Be @("W_0", "W_1", "W_2", "W_3")
    Get-Content GFX:\Weights\W_0 | Should -Be '1'
    Get-Content GFX:\Weights\W_1 | Should -Be '1'
    Get-Content GFX:\Weights\W_2 | Should -Be '1'
    Get-Content GFX:\Weights\W_3 | Should -Be '1'
    Get-Content GFX:\Start | Should -Be '1000'
    Get-Content GFX:\Count | Should -Be '10'
    Get-Content GFX:\OutSeq | Should -Be '80612965543569013375053017657224193322814498804143605698949253030259897351461707903235835255206857522960377247566119902833745107612558849667330639399422732632784532453583865206618002987209702170391793700471749898929136523409356835657014641447629317324840860079447184465668382508012160,155386487112698876882601209682029556632177900932040654518248792050815287733497578518001001590550339537843118599243360180094325020412540796229523519671963959933127789940462658031102391772377739557008973736110891207803031489891423491099112473746284316902564807862289706322535617913392464,299517084062305961271197450060548710193833914774804869385020450471674353347770821611556008473399004135437817486369130162329157490360167590197241792365573002856499027758154485336071405429388900504321726219181254434211653834703163964084106532034135255953816382572802916154130354011249952,577337742246023880714610808747758940875853058358348741598107849896435926088621153807718671865988038028080806972476482727431526331997169238462119255833504794304037971570985304879033739311074383486333975730733496338167528475996628534149112362649902477345101287999082953989896498809588385,1112854278964597732243462486147561401024679372869337871200326345449185464521351261840511517185144239224322120305655092972688753950382436474556215207270464489726449321723186313452825539500050725718056469386497391879111350324000572824989346009877951367526323338513622760932230853242242961,2145095592385626451111871954637898608726544246934532136701703437868111031691240815777787199115081620925683863363744066042543762793152314099445099775141506246820114110992788761699033076012891749265721145072523033859293564124591788814321677378308273417727805816947798337398793323976473762,4134804697658554025341142699593767660820910592937023618885158083685406775648984053037573396639612902313524608128244771904993200565892087402660676030611048533707100432045114865366963760253405758974433316408935176510784096759292154137544242282870262518553046826033306968475051030039555060,7970092311254802089411087949126986611447987271099242368385295716899139197950197284463590784805826800491611398770120413647657243641424007215124110268856524064557701836332075245397856115077422617444544906598689098587356539683881144311004378033706389781152277269493811020795971706067860168,15362846880263580298107565089506214282020121483840135995172483583901842469811773415119462897745665562955141990567764344567882960950850845191786101281879543334811365701093165185916678490843770851402755837466644700836545550891765660087859643704762877084959453250988539087602046913326131951,29612839481562562863971667692864867163015563594810934119144640822354499475102195568398414278306186886685961860829873596163077167951319253909015987356488622179896282080463144058380531442187490977087455205546792009793979751459530747350729941399647802802392583163463455414271862973410020941'
  }
  It "should cache results to avoid unnecessary recomputation" {
    Set-Content GFX:\Order -Value 4
    Set-Content GFX:\Start -Value 1000
    Set-Content GFX:\Count -Value 10
    (Measure-Command { 1..100 | ForEach-Object { Get-Content GFX:\OutSeq } } | Select-Object -ExpandProperty TotalMilliseconds) | Should -BeLessThan 2000
  }
  It "should cache results to avoid unnecessary recomputation (2)" {
    Set-Content GFX:\Order -Value 4
    Set-Content GFX:\Start -Value 1000
    Set-Content GFX:\Count -Value 10
    (Measure-Command { 1..100 | ForEach-Object { Set-Content GFX:\Order -Value 4; Get-Content GFX:\OutSeq } } | Select-Object -ExpandProperty TotalMilliseconds) | Should -BeLessThan 3500
  }
  It "should work for random tests" {
    1..10 | ForEach-Object {
      $order = Get-Random -Minimum 1 -Maximum 11
      $seed = 1..$order | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 }
      $weights = 1..$order | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 }
      $start = Get-Random -Minimum 0 -Maximum 100
      $count = Get-Random -Minimum 1 -Maximum 101
      $expected = @()
      for ($i = 0; $i -lt $order; ++$i) {
        $expected += [bigint]$seed[$i]
      }
      while ($expected.Count -lt $start + $count) {
        $next = 0n
        1..$order | ForEach-Object {
          $next += [bigint]$weights[$PSItem - 1] * $expected[-($order - $PSItem + 1)]
        }
        $expected += $next
      }
      $expected = $expected[$start..($start + $count - 1)] -join ','
      Set-Content GFX:\Order -Value $order
      1..$order | ForEach-Object {
        Set-Content "GFX:\Seed\F_$($PSItem - 1)" -Value $seed[$PSItem - 1]
        Set-Content "GFX:\Weights\W_$($PSItem - 1)" -Value $weights[$PSItem - 1]
      }
      Set-Content GFX:\Start -Value $start
      Set-Content GFX:\Count -Value $count
      Get-Content GFX:\OutSeq | Should -Be $expected
    }
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
