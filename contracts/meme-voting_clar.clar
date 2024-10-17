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

;; Submit a new meme
(define-public (submit-meme)
  (let
    (
      (meme-id (var-get next-meme-id))
    )
    (try! (stx-transfer? (var-get entry-fee) tx-sender (as-contract tx-sender)))
    (map-set memes meme-id {creator: tx-sender, votes: u0, reward: u0})
    (var-set next-meme-id (+ meme-id u1))
    (ok meme-id)
  )
)

;; Vote for a meme
(define-public (vote-for-meme (meme-id uint))
  (let
    (
      (meme (unwrap! (map-get? memes meme-id) (err err-not-found)))
      (user tx-sender)
    )
    (asserts! (is-none (map-get? user-votes {user: user, meme-id: meme-id})) (err err-already-voted))
    (map-set user-votes {user: user, meme-id: meme-id} true)
    (map-set memes meme-id (merge meme {votes: (+ (get votes meme) u1)}))
    (ok true)
  )
)

;; Get meme details
(define-read-only (get-meme (meme-id uint))
  (map-get? memes meme-id)
)

;; Get total number of memes
(define-read-only (get-meme-count)
  (var-get next-meme-id)
)

;; Distribute rewards (to be called periodically)
(define-public (distribute-rewards)
  (let
    (
      (meme-count (var-get next-meme-id))
    )
    (map distribute-reward (list-meme-ids meme-count))
    (ok true)
  )
)
