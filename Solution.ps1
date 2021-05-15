using namespace Microsoft.PowerShell.SHiPS

class GenFibX : SHiPSDirectory
{
  [OutSeq]$OutSeq

  GenFibX([string]$name) : base($name)
  {
    $seed = [Seed]::new("Seed", "F_", 2)
    $weights = [Weights]::new("Weights", "W_", 2)
    $order = [Order]::new("Order", 2, $seed, $weights)
    $start = [InParam]::new("Start", 0)
    $count = [InParam]::new("Count", 10)
    $this.OutSeq = [OutSeq]::new("OutSeq", $order, $start, $count)
  }

  [object[]]GetChildItem()
  {
    return @($this.OutSeq.Order, $this.OutSeq.Order.Seed, $this.OutSeq.Order.Weights, $this.OutSeq.Start, $this.OutSeq.Count, $this.OutSeq)
  }
}

class Seed : SHiPSDirectory
{
  [string]$Prefix
  [InParam[]]$Params

  Seed([string]$name, [string]$prefix, [int]$order): base($name)
  {
    $this.Prefix = $prefix
    $this.Params = @()
    for ($i = 0; $i -lt $order; ++$i) {
      if ($i + 1 -lt $order) {
        $this.Params += [InParam]::new("$($this.Prefix)$i", 0)
      } else {
        $this.Params += [InParam]::new("$($this.Prefix)$i", 1)
      }
    }
  }

  [bool]IsAnyModified()
  {
    for ($i = 0; $i -lt $this.Params.Count; ++$i) {
      if ($this.Params[$i].IsModified()) {
        return $True
      }
    }
    return $False
  }

  [void]SetOrder([int]$order) {
    if ($order -eq $this.Params.Count) {
      return
    }
    $this.Params = @()
    for ($i = 0; $i -lt $order; ++$i) {
      if ($i + 1 -lt $order) {
        $this.Params += [InParam]::new("$($this.Prefix)$i", 0)
      } else {
        $this.Params += [InParam]::new("$($this.Prefix)$i", 1)
      }
    }
  }

  [object[]]GetChildItem()
  {
    return $this.Params
  }

  [void]MarkAllUnmodified()
  {
    for ($i = 0; $i -lt $this.Params.Count; ++$i) {
      $this.Params[$i].MarkUnmodified()
    }
  }
}

class Weights : SHiPSDirectory
{
  [string]$Prefix
  [InParam[]]$Params

  Weights([string]$name, [string]$prefix, [int]$order): base($name)
  {
    $this.Prefix = $prefix
    $this.Params = @()
    for ($i = 0; $i -lt $order; ++$i) {
      $this.Params += [InParam]::new("$($this.Prefix)$i", 1)
    }
  }

  [bool]IsAnyModified()
  {
    for ($i = 0; $i -lt $this.Params.Count; ++$i) {
      if ($this.Params[$i].IsModified()) {
        return $True
      }
    }
    return $False
  }

  [void]SetOrder([int]$order) {
    if ($order -eq $this.Params.Count) {
      return
    }
    $this.Params = @()
    for ($i = 0; $i -lt $order; ++$i) {
      $this.Params += [InParam]::new("$($this.Prefix)$i", 1)
    }
  }

  [object[]]GetChildItem()
  {
    return $this.Params
  }

  [void]MarkAllUnmodified()
  {
    for ($i = 0; $i -lt $this.Params.Count; ++$i) {
      $this.Params[$i].MarkUnmodified()
    }
  }
}

class Order : SHiPSLeaf
{
  [int]$Value
  [Seed]$Seed
  [Weights]$Weights
  [bool]$Modified

  Order([string]$name, [int]$value, [Seed]$seed, [Weights]$weights) : base($name)
  {
    $this.Value = $value
    $this.Seed = $seed
    $this.Weights = $weights
    $this.Modified = $True
  }

  [string]GetContent()
  {
    return [string]$this.Value
  }

  [bool]SetContent([string]$value, [string]$path)
  {
    $newValue = [int]$value
    if ($newValue -eq $this.Value) {
      return $False
    }
    if ($newValue -lt 0) {
      Write-Error "Cannot set Order to value less than zero!"
      return $False
    }
    $this.Value = $newValue
    $this.Seed.SetOrder($this.Value)
    $this.Weights.SetOrder($this.Value)
    $this.Modified = $True
    return $True
  }

  [void]MarkAllUnmodified()
  {
    $this.Modified = $False
    $this.Seed.MarkAllUnmodified()
    $this.Weights.MarkAllUnmodified()
  }

  [bool]IsAnyModified()
  {
    if ($this.Modified) {
      return $True
    }
    if ($this.Seed.IsAnyModified()) {
      return $True
    }
    if ($this.Weights.IsAnyModified()) {
      return $True
    }
    return $False
  }
}

class InParam : SHiPSLeaf
{
  [int]$Value
  [bool]$Modified

  InParam([string]$name, [int]$value) : base($name)
  {
    $this.Value = $value
    $this.Modified = $True
  }

  [string]GetContent()
  {
    return [int]$this.Value
  }

  [bool]SetContent([string]$value, [string]$path)
  {
    $newValue = [int]$value
    if ($newValue -eq $this.Value) {
      return $False
    }
    if ($newValue -lt 0) {
      Write-Error "Cannot set parameter to less than 0!"
      return $False
    }
    $this.Value = $newValue
    $this.Modified = $True
    return $True
  }

  [void]MarkUnmodified()
  {
    $this.Modified = $False
  }

  [bool]IsModified()
  {
    return $this.Modified
  }
}

class OutSeq : SHiPSLeaf
{
  [bigint[]]$Value
  [Order]$Order
  [InParam]$Start
  [InParam]$Count

  OutSeq([string]$name, [Order]$order, [InParam]$start, [InParam]$count): base($name)
  {
    $this.Value = $null
    $this.Order = $order
    $this.Start = $start
    $this.Count = $count
  }

  [bool]IsCached()
  {
    if ($this.Value -eq $null) {
      return $False
    }
    if ($this.Order.IsAnyModified()) {
      return $False
    }
    if ($this.Start.IsModified()) {
      return $False
    }
    if ($this.Count.IsModified()) {
      return $False
    }
    return $True
  }

  [string]GetContent()
  {
    if ($this.IsCached()) {
      return $this.Value -join ','
    }
    $this.Order.MarkAllUnmodified()
    $this.Start.MarkUnmodified()
    $this.Count.MarkUnmodified()
    $this.Value = @()
    if ($this.Count.Value -eq 0) {
      return $this.Value -join ','
    }
    for ($i = 0; $i -lt $this.Order.Value; ++$i) {
      $this.Value += [bigint]$this.Order.Seed.Params[$i].Value
    }
    while ($this.Value.Count -lt $this.Start.Value + $this.Count.Value) {
      $next = 0n
      for ($i = 0; $i -lt $this.Order.Value; ++$i) {
        $next += [bigint]$this.Order.Weights.Params[$i].Value * $this.Value[-($this.Order.Value - $i)]
      }
      $this.Value += $next
    }
    $this.Value = $this.Value[$this.Start.Value..($this.Start.Value + $this.Count.Value - 1)]
    return $this.Value -join ','
  }
}
