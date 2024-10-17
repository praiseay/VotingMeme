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

;; Helper function to distribute reward for a single meme
(define-private (distribute-reward (meme-id uint))
  (let
    (
      (meme (unwrap! (map-get? memes meme-id) (err err-not-found)))
      (reward (calculate-reward (get votes meme)))
    )
    (if (> reward u0)
      (begin
        (try! (as-contract (mint-tokens (get creator meme) reward)))
        (map-set memes meme-id (merge meme {reward: (+ (get reward meme) reward)}))
        (ok true)
      )
      (ok false)
    )
  )
)

;; Calculate reward based on votes (simple linear model)
(define-private (calculate-reward (votes uint))
  (* votes u1) ;; 1 token per vote
)

;; Helper function to create a list of meme IDs
(define-private (list-meme-ids (count uint))
  (map uint-to-buff (unwrap-panic (as-max-len? (list-of-n count) u1000)))
)

;; Helper function to convert uint to buff
(define-private (uint-to-buff (id uint))
  (unwrap-panic (to-consensus-buff? id))
)

;; Initialize the contract
(begin
  (try! (ft-mint? my-token u1000000000 contract-owner))
)
