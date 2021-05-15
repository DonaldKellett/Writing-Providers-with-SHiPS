## What is a provider?

A provider is an abstraction of the Windows filesystem model that allows various forms of data and components not otherwise readily accessible through PowerShell such as the Windows registry or environment to be accessed and manipulated like filesystem drives. The noun used to refer to providers is `PSProvider` and an instance of a provider is known as a `PSDrive`.

You can learn more about providers by running the following PowerShell command:

```powershell
PS> Get-Help about_Providers
```

## SHiPS: Simple Hierarchy in PowerShell

SHiPS is a PowerShell provider. More accurately, it is a framework that simplifies the development of PowerShell providers, by providing classes such as `SHiPSDirectory` and `SHiPSLeaf` for you to inherit from. The framework was originally designed to structure the development of Azure Cloud Shell, a provider that allows Azure cloud resources to be traversed and manipulated like a filesystem drive.

To learn how to develop your own providers using SHiPS, you may wish to refer to the [official repo](https://github.com/PowerShell/SHiPS) for some examples.

## Task

We will be developing a provider for generalized Fibonacci sequences in this Kata.

### Definition

We define a $k$-th order Fibonacci sequence with seed (initial terms) $F_0$, $F_1$, ..., $F_{k - 1}$ and weights $W_0$, $W_1$, ..., $W_{k - 1}$ such that $F_n = \sum_{i=0}^{k - 1} W_i F_{n - k + i}$ whenever $n \geq k$. For example, the typical Fibonacci sequence has order 2 with $F_0 = 0$, $F_1 = 1$, $W_0 = W_1 = 1$.

### Implementation

The provider can be implemented however you wish, as long as it satisfies the criteria listed below.

First of all, your provider must be developed using SHiPS and provide a class `GenFibX` for the root directory such that a new `PSDrive` can be created as follows:

```powershell
PS> New-PSDrive -Name GFX -PSProvider SHiPS -Root Solution#GenFibX
```

Assume your solution code is in a PowerShell module `Solution.psm1`. You can ignore any warnings that pop up when the above command is executed.

The drive `GFX:` should then expose the following directory structure:

- `Order`
- `Seed`
  - `F_0`
  - `F_1`
  - ...
  - `F_(k - 1)`
- `Weights`
  - `W_0`
  - `W_1`
  - ...
  - `W_(k - 1)`
- `Start`
- `Count`
- `OutSeq`

Here, we assume the Fibonacci sequence has order $k$. Any items above that do not contain child items themselves (e.g. `Order`, `Start`, `Count`) should be a leaf and everything else is a directory. By default:

- `GFX:\Order` has value 2
- `GFX:\Seed` has $k$ child items when the order is $k$:
  - `GFX:\Seed\F_i` has value 0 if $i < k - 1$; 1 otherwise
- `GFX:\Weights` has $k$ child items when the order is $k$:
  - `GFX:\Weights\W_i` has value 1 for any $i$
- `GFX:\Start` has value 0
- `GFX:\Count` has value 10

All parameters mentioned above are read-write, meaning that they should support both `Get-Content` and `Set-Content` (except directories, which should support `Get-ChildItem` instead). Valid values for `Set-Content` are non-negative integers that can fit into an `int`. When a negative integer is passed in, your provider should ideally print an error message (not tested) and retain the original value. You can assume other data types (such as a string) will not be written to any parameters in `GFX:`.

The `GFX:\OutSeq` parameter is special: it is a read-only parameter (meaning only `Get-Content` needs to be supported) containing a comma-separated list of terms in the sequence based on other parameter values. For example, in the default scenario, it should contain a second-order Fibonacci sequence with $F_0 = 0$, $F_1 = 1$, $W_0 = W_1 = 1$ of length 10 starting from $F_0$, i.e. `0,1,1,2,3,5,8,13,21,34`. Make sure the value of `GFX:\OutSeq` changes accordingly as the other parameters are modified.

It is worth mentioning that as `GFX:\Order` is overwritten with a _different_ value `m != k`, `GFX:\Seed` and `GFX:\Weights` should automatically reset such that they now have $m$ child items each, with:

- `GFX:\Seed\F_i` having value 0 if $i < m - 1$; 1 otherwise
- `GFX:\Weights\W_i` having value 1 for any $i$

If `GFX:\Order` is overwritten with the _same_ value, nothing should occur, i.e. `GFX:\Seed` and `GFX:\Weights` retain their contents.

Now, some edge cases:

- A sequence with order 0 is such that $F_i = 0$ for any $i$
- A sequence with order 1 is a geometric sequence with initial term $F_0$ and common ratio $W_0$

Why these edge cases make sense is left to the reader as an exercise.

Then, with performance and optimizations:

- While all input parameters can be expected to fit into an `int`, the same cannot be said for terms in the generated sequence. Make sure your implementation correctly handles arbitrarily large terms in the sequence such that there are no surprises with integer overflow.
- When the start and/or count parameters are large, it make take a significant time to compute the sequence. Make sure your implementation does not recompute `GFX:\OutSeq` unless absolutely necessary.

Enjoy scripting, and hope you found this exercise useful :-)

## Final Remarks

While this should not affect how you solve this Kata, keep in mind that PowerShell submissions run in a Linux environment on Codewars, not Windows.
