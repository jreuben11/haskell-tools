-- | Show instance for Haskell AST representation ignoring source and semantic information
{-# LANGUAGE FlexibleContexts, StandaloneDeriving #-}
module Language.Haskell.Tools.AST.Instances.Show () where

import Language.Haskell.Tools.AST.Ann (Ann(..), AnnListG(..), AnnMaybeG(..))
import Language.Haskell.Tools.AST.Representation.Binds
import Language.Haskell.Tools.AST.Representation.Decls
import Language.Haskell.Tools.AST.Representation.Exprs
import Language.Haskell.Tools.AST.Representation.Kinds (UPromoted(..), UKind(..), UKindConstraint(..))
import Language.Haskell.Tools.AST.Representation.Literals (ULiteral(..))
import Language.Haskell.Tools.AST.Representation.Modules
import Language.Haskell.Tools.AST.Representation.Names
import Language.Haskell.Tools.AST.Representation.Patterns (UPatternField(..), UPattern(..))
import Language.Haskell.Tools.AST.Representation.Stmts
import Language.Haskell.Tools.AST.Representation.TH
import Language.Haskell.Tools.AST.Representation.Types

-- Annotations
instance (Show (e dom stage)) => Show (Ann e dom stage) where
  show (Ann _ e) = show e

instance (Show (e dom stage)) => Show (AnnMaybeG e dom stage) where
  show (AnnMaybeG _ e) = show e

instance (Show (e dom stage)) => Show (AnnListG e dom stage) where
  show (AnnListG _ e) = show e

-- Modules
deriving instance Show (UModule dom stage)
deriving instance Show (UModuleHead dom stage)
deriving instance Show (UExportSpecs dom stage)
deriving instance Show (UExportSpec dom stage)
deriving instance Show (UIESpec dom stage)
deriving instance Show (USubSpec dom stage)
deriving instance Show (UModulePragma dom stage)
deriving instance Show (UFilePragma dom stage)
deriving instance Show (UImportDecl dom stage)
deriving instance Show (UImportSpec dom stage)
deriving instance Show (UImportModifier dom stage)
deriving instance Show (UImportQualified dom stage)
deriving instance Show (UImportSource dom stage)
deriving instance Show (UImportSafe dom stage)
deriving instance Show (UTypeNamespace dom stage)
deriving instance Show (UImportRenaming dom stage)

-- Declarations
deriving instance Show (UDecl dom stage)
deriving instance Show (UClassBody dom stage)
deriving instance Show (UClassElement dom stage)
deriving instance Show (UDeclHead dom stage)
deriving instance Show (UInstBody dom stage)
deriving instance Show (UInstBodyDecl dom stage)
deriving instance Show (UGadtConDecl dom stage)
deriving instance Show (UGadtConType dom stage)
deriving instance Show (UFieldWildcard dom stage)
deriving instance Show (UFunDeps dom stage)
deriving instance Show (UFunDep dom stage)
deriving instance Show (UConDecl dom stage)
deriving instance Show (UFieldDecl dom stage)
deriving instance Show (UDeriving dom stage)
deriving instance Show (UDeriveStrategy dom stage)
deriving instance Show (UInstanceRule dom stage)
deriving instance Show (UInstanceHead dom stage)
deriving instance Show (UTypeEqn dom stage)
deriving instance Show (UKindConstraint dom stage)
deriving instance Show (UTyVar dom stage)
deriving instance Show (UType dom stage)
deriving instance Show (UKind dom stage)
deriving instance Show (UContext dom stage)
deriving instance Show (UAssertion dom stage)
deriving instance Show (UExpr dom stage)
deriving instance Show (expr dom stage) => Show (UStmt' expr dom stage)
deriving instance Show (UCompStmt dom stage)
deriving instance Show (UValueBind dom stage)
deriving instance Show (UPattern dom stage)
deriving instance Show (UPatternField dom stage)
deriving instance Show (USplice dom stage)
deriving instance Show (QQString dom stage)
deriving instance Show (UMatch dom stage)
deriving instance Show (expr dom stage) => Show (UAlt' expr dom stage)
deriving instance Show (URhs dom stage)
deriving instance Show (UGuardedRhs dom stage)
deriving instance Show (UFieldUpdate dom stage)
deriving instance Show (UBracket dom stage)
deriving instance Show (UTopLevelPragma dom stage)
deriving instance Show (URule dom stage)
deriving instance Show (URuleVar dom stage)
deriving instance Show (UAnnotationSubject dom stage)
deriving instance Show (UMinimalFormula dom stage)
deriving instance Show (UExprPragma dom stage)
deriving instance Show (USourceRange dom stage)
deriving instance Show (Number dom stage)
deriving instance Show (UQuasiQuote dom stage)
deriving instance Show (URhsGuard dom stage)
deriving instance Show (ULocalBind dom stage)
deriving instance Show (ULocalBinds dom stage)
deriving instance Show (UFixitySignature dom stage)
deriving instance Show (UTypeSignature dom stage)
deriving instance Show (UListCompBody dom stage)
deriving instance Show (UTupSecElem dom stage)
deriving instance Show (UTypeFamily dom stage)
deriving instance Show (UTypeFamilySpec dom stage)
deriving instance Show (UInjectivityAnn dom stage)
deriving instance Show (expr dom stage) => Show (UCaseRhs' expr dom stage)
deriving instance Show (expr dom stage) => Show (UGuardedCaseRhs' expr dom stage)
deriving instance Show (UPatternSynonym dom stage)
deriving instance Show (UPatSynRhs dom stage)
deriving instance Show (UPatSynLhs dom stage)
deriving instance Show (UPatSynWhere dom stage)
deriving instance Show (UPatternTypeSignature dom stage)
deriving instance Show (URole dom stage)
deriving instance Show (UCmd dom stage)
deriving instance Show (ULanguageExtension dom stage)
deriving instance Show (UMatchLhs dom stage)
deriving instance Show (UInlinePragma dom stage)
deriving instance Show (USpecializePragma dom stage)
deriving instance Show (UUnboxedSumPlaceHolder dom stage)


-- ULiteral
deriving instance Show (ULiteral dom stage)
deriving instance Show (k dom stage) => Show (UPromoted k dom stage)

-- Base
deriving instance Show (UOperator dom stage)
deriving instance Show (UName dom stage)
deriving instance Show (UQualifiedName dom stage)
deriving instance Show (UModuleName dom stage)
deriving instance Show (UNamePart dom stage)
deriving instance Show (UStringNode dom stage)
deriving instance Show (UDataOrNewtypeKeyword dom stage)
deriving instance Show (UDoKind dom stage)
deriving instance Show (TypeKeyword dom stage)
deriving instance Show (UOverlapPragma dom stage)
deriving instance Show (UCallConv dom stage)
deriving instance Show (UArrowAppl dom stage)
deriving instance Show (USafety dom stage)
deriving instance Show (UConlikeAnnot dom stage)
deriving instance Show (Assoc dom stage)
deriving instance Show (Precedence dom stage)
deriving instance Show (LineNumber dom stage)
deriving instance Show (UPhaseControl dom stage)
deriving instance Show (PhaseNumber dom stage)
deriving instance Show (PhaseInvert dom stage)
