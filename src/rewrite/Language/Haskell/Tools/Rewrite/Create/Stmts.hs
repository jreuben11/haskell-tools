-- | Generation of statement-level AST fragments for refactorings.
-- The bindings defined here are the AST constructor names with an "mk" prefix.
{-# LANGUAGE OverloadedStrings 
           , TypeFamilies 
           #-}
module Language.Haskell.Tools.Rewrite.Create.Stmts where

import Language.Haskell.Tools.AST (UCompStmt(..), UListCompBody(..), UStmt'(..))
import Language.Haskell.Tools.PrettyPrint.Prepare
import Language.Haskell.Tools.Rewrite.Create.Utils (mkAnn, mkAnnList, mkAnnMaybe)
import Language.Haskell.Tools.Rewrite.ElementTypes

-- | Creates a binding statement (@ x <- action @)
mkBindStmt :: Pattern dom -> Expr dom -> Stmt dom
mkBindStmt bound expr = mkAnn (child <> " <- " <> child) $ UBindStmt bound expr

-- | Creates a non-binding statement (@ action @)
mkExprStmt :: Expr dom -> Stmt dom
mkExprStmt = mkAnn child . UExprStmt

-- | Creates a let statement (@ let x = 3; y = 4 @)
mkLetStmt :: [LocalBind dom] -> Stmt dom
mkLetStmt = mkAnn ("let " <> child) . ULetStmt . mkAnnList (indented list)

-- | Creates a recursive binding statement with (@ rec b <- f a c; c <- f b a @)
mkRecStmt :: [Stmt dom] -> Stmt dom
mkRecStmt = mkAnn ("rec " <> child) . URecStmt . mkAnnList (indented list)

-- * List comprehensions

-- | Body of a list comprehension: (@ | x <- [1..10] @)
mkListCompBody :: [CompStmt dom] -> ListCompBody dom
mkListCompBody = mkAnn child . UListCompBody . mkAnnList (separatedBy " " list)

-- | Normal monadic statement of a list comprehension
mkCompStmt :: Stmt dom -> CompStmt dom
mkCompStmt = mkAnn child . UCompStmt

-- | Then statements by @TransformListComp@ (@ then sortWith by (x + y) @)
mkThenStmt :: Expr dom -> Maybe (Expr dom) -> CompStmt dom
mkThenStmt th by = mkAnn ("then " <> child) 
                     $ UThenStmt th $ mkAnnMaybe (after " by " opt) by

-- | Grouping statements by @TransformListComp@ (@ then group by (x + y) using groupWith @) 
mkGroupStmt :: Maybe (Expr dom) -> Maybe (Expr dom) -> CompStmt dom
mkGroupStmt by using = mkAnn ("then group" <> child) 
                         $ UGroupStmt (mkAnnMaybe (after " by " opt) by)
                                      (mkAnnMaybe (after " using " opt) using)

-- * Commands

-- | Creates a binding command (@ x <- action @)
mkBindCmd :: Pattern dom -> Cmd dom -> CmdStmt dom
mkBindCmd bound expr = mkAnn (child <> " <- " <> child) $ UBindStmt bound expr

-- | Creates a non-binding command (@ action @)
mkExprCmd :: Cmd dom -> CmdStmt dom
mkExprCmd = mkAnn child . UExprStmt

-- | Creates a let command (@ let x = 3; y = 4 @)
mkLetStmtCmd :: [LocalBind dom] -> CmdStmt dom
mkLetStmtCmd = mkAnn ("let " <> child) . ULetStmt . mkAnnList (indented list)

-- | Creates a recursive binding command with (@ rec b <- f a c; c <- f b a @)
mkRecCmd :: [CmdStmt dom] -> CmdStmt dom
mkRecCmd = mkAnn ("rec " <> child) . URecStmt . mkAnnList (indented list)

