{-# LANGUAGE CPP               #-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Plutus.V1.Ledger.Crypto (PubKeyHash (..))
import Test.Tasty              (defaultMain, testGroup)

import Plutonomy      (validatorToRaw)
import Plutonomy.Test

import qualified MultiSig

main :: IO ()
main = defaultMain $ testGroup "plutonomy"
    [ plutonomyTests TestOptions
        { toName        = "multisig"

#if PLUTUS_VER == 1
        , toUnoptSize   = (2928,2532)
#elif PLUTUS_VER == 2
        , toUnoptSize   = (2923,2432)
#elif PLUTUS_VER == 3
        , toUnoptSize   = (2651,2210)
#else
        , toUnoptSize   = (0,0)
#endif

#if PLUTUS_VER == 3
        -- plutus-tx makes our life harder: https://github.com/input-output-hk/plutus/issues/4578
        , toOptSize     = (1959,1695)
        , toAggSize     = (1961,1665)
#else
        , toOptSize     = (1891,1645) -- 65% of original
        , toAggSize     = (1893,1615)
#endif

        , toTerm        = validatorToRaw $ MultiSig.validator' multisigParams
#if PLUTUS_VER == 1
        , toFixturesDir = "fixtures-1"
#elif PLUTUS_VER == 2
        , toFixturesDir = "fixtures-2"
#elif PLUTUS_VER == 3
        , toFixturesDir = "fixtures-3"
#else
        , toFixturesDir = error "Invalid configuration"
#endif
        }
    ]

multisigParams :: MultiSig.MultiSig
multisigParams = MultiSig.MultiSig
    { MultiSig.signatories =
        [ PubKeyHash "some-string-which-is-28-long"
        , PubKeyHash "s0me-string-which-is-28-long"
        , PubKeyHash "some-string-which-is-28-l0ng"
        ]
    , MultiSig.minNumSignatures = 2
    }
