%if False
\begin{code}
open import ClosedSemiRingRecord

module LiftCSR (csr : ClosedSemiRing) where

open import Data.Product renaming (_,_ to _,,_)
open import Product
import Relation.Binary.EqReasoning as EqReasoning
open import Relation.Binary.PropositionalEquality using (refl)

open import Shape
open import Matrix

open import SemiRingRecord
open import SemiNearRingRecord

import LiftSR renaming (Square to SquareSR; <*S> to <*>; <+S> to <+>; oneS to I)

open ClosedSemiRing csr
open SemiRing sr
open SemiNearRing snr

open LiftSR sr

infixr 60 _*_
_*_ = _*S_
infixr 50 _+_
_+_ = _+S_

\end{code}
%endif

\citet{lehmann1977} presents a definition of the closure on
square matrices, \(A^* = 1 + A \cdot A^*\):
%
Given a square matrix
%
\[
  A = \Quad[1ex]
    {A_{11}}{A_{12}}
    {A_{21}}{A_{22}}
\]
%
the transitive closure of $A$ is defined inductively as
%
\begin{align*}
  A^*
  & =
  \Quad[1ex]{A_{11}^* + A_{11}^* \cdot A_{12} \cdot \Delta^* \cdot A_{21} \cdot A_{11}^*}
            {A_{11}^* \cdot A_{12} \cdot \Delta^*}
            {\Delta^* \cdot A_{21} \cdot A_{11}^*}
            {\Delta^*}
\end{align*}
%
where $\Delta = A_{22} + A_{21} \cdot A_{11}^* \cdot A_{12}$ and the
base case is the 1-by-1 matrix where we use the transitive closure of
the element of the matrix:
%
\(
\boxed{a}\,^* = \boxed{a^*}
\).

We have encoded this definition of closure in Agda and implemented a
constructive correctness proof using structural induction and
equational reasoning.
%
The full development of around 2500 lines of literate Agda code
(including this abstract) is available on GitHub
(\url{https://github.com/DSLsofMath/FLABloM}).

%if False
\begin{code}
EqS : ∀ {sh} → M s sh sh → M s sh sh → Set
EqS w c = I + w * c ≃S c

-- from Lehmann
lemma2-1-1 :  ∀ sh sh1 (A : M s sh sh) (R : M s sh sh1) →
              (I + A) * R  ≃S  R + A * R
lemma2-1-1 sh sh1 A R =
  let open EqReasoning setoidS
  in begin
    (I + A) * R
  ≈⟨ distrS R I A ⟩
    I * R  +  A * R
  ≈⟨ <+> sh sh1 (*-identlS R) (reflS sh sh1) ⟩
    R  +  A * R
  ∎

private
  module lemma1
    (sh sh1 : Shape)
    (C C* : M s sh sh)
    (D    : M s sh sh1)
    (E    : M s sh1 sh)
    (Δ*   : M s sh1 sh1)
    (ih   : C* ≃S I + C * C*) where

    X = D * Δ* * E * C*

    entire-lem1 : C* * X  ≃S  C * C* * X  +  X
    entire-lem1 =
      let open EqReasoning setoidS
      in begin
        C*            * X
      ≈⟨ <*> sh sh sh ih (reflS sh sh) ⟩
        (I + C * C*)  * X
      ≈⟨ distrS (X) I (C * C*) ⟩
        I * X  +  (C * C*) * X
      ≈⟨ <+> sh sh
             (*-identlS X)
             (*-assocS sh sh sh sh C C* X) ⟩
             X  +  C * C* * X
      ≈⟨ commS sh sh X (C * C* * X) ⟩
        C * C* * X
               + X
      ∎

open lemma1 public using (entire-lem1)

private
  module lemma2
    (sh sh1 : Shape)
    (C C* : M s sh sh)
    (D    : M s sh sh1) (E : M s sh1 sh)
    (Δ*   : M s sh1 sh1) where

    X = D * Δ* * E * C*

    entire-lem2 :
      C * C*  +  (C * C* * X  +  X) ≃S
      C * (C* +       C* * X) +  X
    entire-lem2 =
      let open EqReasoning setoidS
      in begin
        C * C*  +  (C * C* * X  +  X)
      ≈⟨ symS sh sh (assocS sh sh (C * C*) (C * C* * X) X) ⟩
        (C * C*  +   C * C* * X) +  X
      ≈⟨ <+> sh sh
         (symS sh sh
           (distlS C C* (C* * X)))
           (reflS sh sh) ⟩
         C * (C* + C* * X)  +  X
      ∎

open lemma2 public using (entire-lem2)

private
  module lemma3
    (sh sh1 : Shape)
    (C* : M s sh sh)
    (D : M s sh sh1)
    (E : M s sh1 sh)
    (F : M s sh1 sh1)
    (Δ* : M s sh1 sh1) where

    Δ : M s sh1 sh1
    Δ = F + E * C* * D

    entire-lem3 :
      (Δ * Δ*) * E * C* ≃S
      E * C* * D * Δ* * E * C*
        + F            * Δ* * E * C*
    entire-lem3 =
      let open EqReasoning setoidS
      in begin
          (Δ * Δ*) * E * C*
        ≈⟨ *-assocS sh1 sh1 sh1 sh Δ Δ* (E * C*)  ⟩ -- *-assocS
          Δ * Δ* * E * C*
        ≡⟨ refl ⟩ -- def of Δ
          (F + E * C* * D) * Δ* * E * C*
        ≈⟨ (distrS {sh1}{sh1}{sh}
             (Δ* * E * C*) F (E * C* * D)) ⟩ -- <+> reflS distrS
         F              * Δ* * E * C*
         + (E * C* * D) * Δ* * E * C*
        ≈⟨ (commS sh1 sh (F * Δ* * E * C*) ((E * C* * D) * Δ* * E * C*)) ⟩ -- <+> reflS commS
         (E * C* * D) * Δ* * E * C*
         + F           * Δ* * E * C*
        ≈⟨ <+> sh1 sh {(E * C* * D) * Δ* * E * C*}{((E * C*) * D) * Δ* * E * C*}
                {F * Δ* * E * C*}{F * Δ* * E * C*}
             (<*> sh1 sh1 sh {(E * C* * D)}{(E * C*) * D}{Δ* * E * C*}{Δ* * E * C*}
               (symS sh1 sh1 {(E * C*) * D}{E * C* * D}
                 (*-assocS sh1 sh sh sh1
                   E C* D))
               (reflS sh1 sh))
             (reflS sh1 sh) ⟩ -- (<+> *-assocS reflS)
          ((E * C*) * D) * Δ* * E * C*
          + F           * Δ* * E * C*
        ≈⟨ <+> sh1 sh {((E * C*) * D) * Δ* * E * C*}{(E * C*) * D * Δ* * E * C*}
                {F * Δ* * E * C*}{F * Δ* * E * C*}
             (*-assocS sh1 sh sh1 sh
               (E * C*) D (Δ* * E * C*))
             (reflS sh1 sh) ⟩ -- (<+> *-assocS reflS)
          (E * C*) * D * Δ* * E * C*
          + F           * Δ* * E * C*
        ≈⟨ <+> sh1 sh {(E * C*) * D * Δ* * E * C*}{E * C* * D * Δ* * E * C*}
                {_}{_}
             (*-assocS sh1 sh sh sh
               E C* (D * Δ* * E * C*))
             (reflS sh1 sh) ⟩ -- (<+> *-assocS reflS)
          E * C* * D * Δ* * E * C*
          + F           * Δ* * E * C*
        ∎

open lemma3 public using (entire-lem3)

entireQS : ∀ {sh} (c : M s sh sh) → Σ (M s sh sh) λ c* → c* ≃S I + c * c*
entireQS {L} (One w) =
  let (c ,, p) = entireQ w
  in (One c ,, p)
entireQS {B sh sh1} (Q C D
                       E F) =
  let
    C* ,, ih_C = entireQS C
    Δ = F + E * C* * D
    Δ* ,, ih_Δ = entireQS Δ
  in
    Q  (C* + C* * D * Δ* * E * C*)  (C* * D * Δ*)
       (Δ* * E * C*)                   Δ* ,,
    (let open EqReasoning setoidS
    in begin
      C* + C* * D * Δ* * E * C*
    ≈⟨ <+> sh sh
            {C*}{I + C * C*}{C* * D * Δ* * E * C*}
            {C * C* * D * Δ* * E * C*  +  D * Δ* * E * C*}
         ih_C
         (entire-lem1 sh sh1 C C* D E Δ* ih_C) ⟩
      (I + C * C*)
        + C * C* * D * Δ* * E * C* + D * Δ* * E * C*
    ≈⟨ assocS sh sh I (C * C*) (C * C* * D * Δ* * E * C* + D * Δ* * E * C*)  ⟩
      I + C * C*
        + C * C* * D * Δ* * E * C* + D * Δ* * E * C*
    ≈⟨ <+> sh sh {I}{I}
            {C * C* + C * C* * D * Δ* * E * C* + D * Δ* * E * C*}
            {(C * (C* + C* * D * Δ* * E * C*) + D * Δ* * E * C*)}
         (reflS sh sh)
         (entire-lem2 sh sh1 C C* D E Δ*) ⟩
      I + C * (C* + C* * D * Δ* * E * C*) + D * Δ* * E * C*
    ∎) ,
    (let open EqReasoning setoidS
    in begin
      C* * D * Δ*
    ≈⟨ <*> sh sh sh1 {C*}{I + C * C*}
            {D * Δ*}{D * Δ*}
         ih_C (reflS sh sh1) ⟩
      (I + C * C*) * D * Δ*
    ≈⟨ distrS (D * Δ*) I (C * C*) ⟩
      I * (D * Δ*) + (C * C*) * (D * Δ*)
    ≈⟨ <+> sh sh1 {I * (D * Δ*)}{D * Δ*}{_}{_}
         (*-identlS (D * Δ*))
         (reflS sh sh1) ⟩
      D * Δ* + (C * C*) * (D * Δ*)
    ≈⟨ commS sh sh1 (D * Δ*) ((C * C*) * (D * Δ*)) ⟩
      (C * C*) * D * Δ* + D * Δ*
    ≈⟨ <+> sh sh1 {(C * C*) * D * Δ*}{C * C* * D * Δ*}{_}{_}
         (*-assocS sh sh sh sh1 C C* (D * Δ*))
         (reflS sh sh1) ⟩
      C * C* * D * Δ* + D * Δ*
    ≈⟨ symS sh sh1 {zerS sh sh1 + C * C* * D * Δ* + D * Δ*}
            {C * C* * D * Δ* + D * Δ*}
         (identSˡ sh sh1 (C * C* * D * Δ* + D * Δ*)) ⟩
      zerS sh sh1 + C * C* * D * Δ* + D * Δ*
    ∎) ,
    (let open EqReasoning setoidS
    in begin
      Δ* * E * C*
    ≈⟨ <*> sh1 sh1 sh {Δ*}{I + Δ * Δ*}{E * C*}{E * C*}
         ih_Δ
         (reflS sh1 sh) ⟩ -- <*> ih_Δ reflS
      (I + Δ * Δ*) * E * C*
    ≈⟨ lemma2-1-1 sh1 sh (Δ * Δ*) (E * C*) ⟩ -- lemma 2.1-1
      E * C* + (Δ * Δ*) * E * C*
    ≈⟨ <+> sh1 sh {E * C*}{E * C*}
            {(Δ * Δ*) * E * C*}{E * C* * D * Δ* * E * C* + F * Δ* * E * C*}
         (reflS sh1 sh)
         (entire-lem3 sh sh1 C* D E F Δ*) ⟩
      E * C*
        + E * C* * D * Δ* * E * C*
        + F            * Δ* * E * C*
    ≈⟨ symS sh1 sh {(E * C*
        + E * C* * D * Δ* * E * C*)
        + F            * Δ* * E * C*}{E * C*
        + E * C* * D * Δ* * E * C*
        + F            * Δ* * E * C*}
         (assocS sh1 sh (E * C*) (E * C* * D * Δ* * E * C*) (F * Δ* * E * C*)) ⟩
      (E * C*
        + E * C* * D * Δ* * E * C*)
        + F            * Δ* * E * C*
    ≈⟨ <+> sh1 sh
            {E * C* + E * C* * D * Δ* * E * C*}{E * (C* + C* * D * Δ* * E * C*)}
            {F * Δ* * E * C*}{F * Δ* * E * C*}
         (symS sh1 sh {E * (C* + C* * D * Δ* * E * C*)}{E * C* + E * C* * D * Δ* * E * C*}
           (distlS E C* (C* * D * Δ* * E * C*)))
         (reflS sh1 sh) ⟩ -- <+> (symS distlS) reflS
      E * (C* + C* * D * Δ* * E * C*)
        + F * Δ* * E * C*
    ≈⟨ symS sh1 sh {zerS sh1 sh
        + (E * (C* + C* * D * Δ* * E * C*)
        + F * Δ* * E * C*)}{E * (C* + C* * D * Δ* * E * C*)
        + F * Δ* * E * C*}
         (identSˡ sh1 sh (E * (C* + C* * D * Δ* * E * C*) + F * Δ* * E * C*)) ⟩ -- symS identSˡ
      zerS sh1 sh
        + E * (C* + C* * D * Δ* * E * C*)
        + F * Δ* * E * C*
    ∎) ,
    (let open EqReasoning setoidS
    in begin
      Δ*
    ≈⟨ ih_Δ ⟩
      I + Δ * Δ*
    ≡⟨ refl ⟩
      I + (F + E * C* * D) * Δ*
    ≈⟨ <+> sh1 sh1 {I}{I}{(F + E * C* * D) * Δ*}{F * Δ* + (E * C* * D) * Δ*}
         (reflS sh1 sh1)
         (distrS Δ* F (E * C* * D)) ⟩
      I + F * Δ* + (E * C* * D) * Δ*
    ≈⟨ <+> sh1 sh1 {_}{_}{F * Δ* + (E * C* * D) * Δ*}{(E * C* * D) * Δ* + F * Δ*}
         (reflS sh1 sh1)
         (commS sh1 sh1 (F * Δ*) ((E * C* * D) * Δ*)) ⟩
      I + (E * C* * D) * Δ* + F * Δ*
    ≈⟨ <+> sh1 sh1 {I}{I}
            {(E * C* * D) * Δ* + F * Δ*}{E * (C* * D) * Δ* + F * Δ*}
         (reflS sh1 sh1)
         (<+> sh1 sh1 {(E * C* * D) * Δ*}{E * (C* * D) * Δ*}
               {F * Δ*}{F * Δ*}
           (*-assocS sh1 sh sh1 sh1 E (C* * D) Δ*)
           (reflS sh1 sh1)) ⟩
      I + E * (C* * D) * Δ* + F * Δ*
    ≈⟨ <+> sh1 sh1 {I}{I}{E * (C* * D) * Δ* + F * Δ*}{E * C* * D * Δ* + F * Δ*}
         (reflS sh1 sh1)
         (<+> sh1 sh1 {E * (C* * D) * Δ*}{E * C* * D * Δ*}{F * Δ*}{F * Δ*}
           (<*> sh1 sh sh1 {E}{E}{(C* * D) * Δ*}{C* * D * Δ*}
             (reflS sh1 sh)
             (*-assocS sh sh sh1 sh1 C* D Δ*))
           (reflS sh1 sh1)) ⟩
      I + E * C* * D * Δ* + F * Δ*
    ∎)

Square : Shape → ClosedSemiRing
Square shape =
  record
    { sr = SquareSR shape
    ; entireQ = entireQS }
\end{code}
%endif
