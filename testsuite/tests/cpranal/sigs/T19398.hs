{-# LANGUAGE BangPatterns #-}

module T19398 where

data T a = MkT !a !a

f :: T a -> T a
f (MkT a b) = MkT b a
{-# NOINLINE f #-}

-- | Should *not* have the CPR property, even though the scrutinee is a
-- variable with the CPR property. It shows how Test (A) of
-- Historical Note [Optimistic field binder CPR] is unsound.
a :: Int -> Int
a n
  | n == 0    = n
  | even n    = case q of MkT x y -> if x == y then x else y
  | otherwise = case q of MkT x y -> if x == y then y else x
  where
    q = f $ f $ f $ f $ f $ f $ f $ MkT n n

-- | Should not have the CPR property, because 'x' will not be unboxed.
-- It shows how Test (C) of Historical Note [Optimistic field binder CPR] is
-- unsound.
c :: (Int, Int) -> Int
c (x,_) = x

-- | An interesting artifact is that the following function has the Nested CPR
-- property, and we could in theory exploit that:
g :: (Int, Int) -> (Int, Int)
g p@(!x, !y) | x == y = error "blah"
g p                   = p
