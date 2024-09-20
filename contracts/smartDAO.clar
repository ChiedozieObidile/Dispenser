;; Define constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VOTED (err u101))
(define-constant ERR_PROPOSAL_ENDED (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u105))
(define-constant ERR_PROPOSAL_ALREADY_EXECUTED (err u106))
(define-constant ERR_INVALID_INPUT (err u107))

;; Define data variables
(define-data-var total-supply uint u1000000) ;; Total number of governance tokens
(define-data-var proposal-count uint u0) ;; Counter for proposal IDs

;; Define data maps
(define-map balances principal uint) ;; Token balances of users
(define-map proposals 
  uint 
  {
    creator: principal,
    title: (string-ascii 50),
    description: (string-utf8 500),
    amount: uint,
    recipient: principal,
    votes-for: uint,
    votes-against: uint,
    end-block: uint,
    executed: bool
  }
)
(define-map votes {proposal-id: uint, voter: principal} bool)

;; Read-only functions

(define-read-only (get-balance (account principal))
  (default-to u0 (map-get? balances account))
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (has-voted (proposal-id uint) (account principal))
  (default-to false (map-get? votes {proposal-id: proposal-id, voter: account}))
)

;; Public functions

(define-public (create-proposal (title (string-ascii 50)) (description (string-utf8 500)) (amount uint) (recipient principal))
  (let
    (
      (proposal-id (+ (var-get proposal-count) u1))
      (caller tx-sender)
    )
    (asserts! (>= (get-balance caller) u1) ERR_UNAUTHORIZED) ;; Must hold at least 1 token to create proposal
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (is-some (as-max-len? title u50)) ERR_INVALID_INPUT) ;; Check title length
    (asserts! (is-some (as-max-len? description u500)) ERR_INVALID_INPUT) ;; Check description length
    (map-set proposals proposal-id
      {
        creator: caller,
        title: title,
        description: description,
        amount: amount,
        recipient: recipient,
        votes-for: u0,
        votes-against: u0,
        end-block: (+ block-height u1440), ;; Proposal lasts ~10 days (assuming 1 block per 10 minutes)
        executed: false
      }
    )
    (var-set proposal-count proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote (proposal-id uint) (vote-for bool))
  (let
    (
      (caller tx-sender)
      (proposal (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
      (voter-balance (get-balance caller))
    )
    (asserts! (< block-height (get end-block proposal)) ERR_PROPOSAL_ENDED)
    (asserts! (not (has-voted proposal-id caller)) ERR_ALREADY_VOTED)
    (asserts! (> voter-balance u0) ERR_UNAUTHORIZED)
    
    (map-set votes {proposal-id: proposal-id, voter: caller} true)
    (if vote-for
      (map-set proposals proposal-id 
        (merge proposal {votes-for: (+ (get votes-for proposal) voter-balance)}))
      (map-set proposals proposal-id 
        (merge proposal {votes-against: (+ (get votes-against proposal) voter-balance)}))
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
    )
    (asserts! (>= block-height (get end-block proposal)) ERR_PROPOSAL_ENDED)
    (asserts! (not (get executed proposal)) ERR_PROPOSAL_ALREADY_EXECUTED)
    (asserts! (> (get votes-for proposal) (get votes-against proposal)) ERR_UNAUTHORIZED)
    
    (try! (as-contract (stx-transfer? (get amount proposal) tx-sender (get recipient proposal))))
    (map-set proposals proposal-id (merge proposal {executed: true}))
    (ok true)
  )
)

(define-public (deposit-stx (amount uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount caller (as-contract tx-sender)))
    (ok true)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (let
    (
      (current-balance (get-balance recipient))
      (new-balance (+ current-balance amount))
      (new-supply (+ (var-get total-supply) amount))
    )
    (asserts! (is-eq tx-sender (as-contract tx-sender)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (var-set total-supply new-supply)
    (map-set balances recipient new-balance)
    (ok true)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (let
    (
      (sender tx-sender)
      (sender-balance (get-balance sender))
      (recipient-balance (get-balance recipient))
    )
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= amount sender-balance) ERR_INSUFFICIENT_BALANCE)
    
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient (+ recipient-balance amount))
    (ok true)
  )
)