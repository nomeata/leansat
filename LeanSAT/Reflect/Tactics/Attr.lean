/-
Copyright (c) 2024 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Lean.Util.Trace
import Lean.Elab.Tactic.Simp

open Lean

initialize registerTraceClass `sat
initialize registerTraceClass `bv

register_option sat.solver : String := {
  defValue := "cadical"
  descr := "name of the SAT solver used by LeanSAT tactics"
}

register_option sat.prevalidate : Bool := {
  defValue := false
  descr := "Usually the LRAT proof is only parsed in the kernel. If this is enabled its additionally parsed before as well for better error reporting."
}

register_simp_attr bv_normalize
