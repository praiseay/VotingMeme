;; meme-voting.clar

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-voted (err u102))

;; Define data variables
(define-data-var next-meme-id uint u0)
(define-data-var entry-fee uint u10) ;; 10 tokens to submit a meme

;; Define data maps
(define-map memes uint {creator: principal, votes: uint, reward: uint})
(define-map user-votes {user: principal, meme-id: uint} bool)

;; Mint reward tokens to user
(define-private (mint-tokens (user principal) (amount uint))
  (ft-mint? my-token amount user))

