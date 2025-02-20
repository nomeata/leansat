import LeanSAT.Reflect.BVExpr.BitBlast.Impl.Expr
import LeanSAT.Reflect.BVExpr.BitBlast.Impl.Carry

namespace BVPred

def mkUlt (aig : AIG BVBit) (pair : ExprPair) : AIG.Entrypoint BVBit :=
  let res := pair.lhs.bitblast aig
  let aig := res.aig
  let lhsRefs := res.stream
  let res := pair.rhs.bitblast aig
  let aig := res.aig
  let rhsRefs := res.stream
  let lhsRefs := lhsRefs.cast <| by
    apply AIG.LawfulStreamOperator.le_size (f := BVExpr.bitblast)
  streamProc aig ⟨lhsRefs, rhsRefs⟩
where
  streamProc {w : Nat} (aig : AIG BVBit) (input : AIG.BinaryRefStream aig w) : AIG.Entrypoint BVBit :=
  let ⟨lhsRefs, rhsRefs⟩ := input
  let res := BVExpr.bitblast.blastNot aig rhsRefs
  let aig := res.aig
  let rhsRefs := res.stream
  let res := aig.mkConstCached true
  let aig := res.aig
  let trueRef := res.ref
  let lhsRefs := lhsRefs.cast <| by
    apply AIG.LawfulOperator.le_size_of_le_aig_size (f := AIG.mkConstCached)
    apply AIG.LawfulStreamOperator.le_size (f := BVExpr.bitblast.blastNot)
  let rhsRefs := rhsRefs.cast <| by
    apply AIG.LawfulOperator.le_size (f := AIG.mkConstCached)
  let res := BVExpr.bitblast.mkOverflowBit aig ⟨_, ⟨lhsRefs, rhsRefs⟩, trueRef⟩
  let aig := res.aig
  let overflowRef := res.ref
  aig.mkNotCached overflowRef

instance mkUlt_inst {w : Nat} : AIG.LawfulOperator BVBit (AIG.BinaryRefStream · w) mkUlt.streamProc where
  le_size := by
    intros
    unfold mkUlt.streamProc
    dsimp
    apply AIG.LawfulOperator.le_size_of_le_aig_size (f := AIG.mkNotCached)
    apply AIG.LawfulOperator.le_size_of_le_aig_size (f := BVExpr.bitblast.mkOverflowBit)
    apply AIG.LawfulOperator.le_size_of_le_aig_size (f := AIG.mkConstCached)
    apply AIG.LawfulStreamOperator.le_size (f := BVExpr.bitblast.blastNot)
  decl_eq := by
    intros
    unfold mkUlt.streamProc
    dsimp
    rw [AIG.LawfulOperator.decl_eq (f := AIG.mkNotCached)]
    rw [AIG.LawfulOperator.decl_eq (f := BVExpr.bitblast.mkOverflowBit)]
    rw [AIG.LawfulOperator.decl_eq (f := AIG.mkConstCached)]
    rw [AIG.LawfulStreamOperator.decl_eq (f := BVExpr.bitblast.blastNot)]
    . apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast.blastNot)
      assumption
    . apply AIG.LawfulOperator.lt_size_of_lt_aig_size (f := AIG.mkConstCached)
      apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast.blastNot)
      assumption
    . apply AIG.LawfulOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast.mkOverflowBit)
      apply AIG.LawfulOperator.lt_size_of_lt_aig_size (f := AIG.mkConstCached)
      apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast.blastNot)
      assumption

instance : AIG.LawfulOperator BVBit (fun _ => ExprPair) mkUlt where
  le_size := by
    intros
    unfold mkUlt
    dsimp
    apply AIG.LawfulOperator.le_size_of_le_aig_size (f := mkUlt.streamProc)
    apply AIG.LawfulStreamOperator.le_size_of_le_aig_size (f := BVExpr.bitblast)
    apply AIG.LawfulStreamOperator.le_size (f := BVExpr.bitblast)
  decl_eq := by
    intros
    unfold mkUlt
    dsimp
    rw [AIG.LawfulOperator.decl_eq (f := mkUlt.streamProc)]
    rw [AIG.LawfulStreamOperator.decl_eq (f := BVExpr.bitblast)]
    rw [AIG.LawfulStreamOperator.decl_eq (f := BVExpr.bitblast)]
    . apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast)
      assumption
    . apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast)
      apply AIG.LawfulStreamOperator.lt_size_of_lt_aig_size (f := BVExpr.bitblast)
      assumption

end BVPred
